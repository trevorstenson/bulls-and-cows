defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias Bulls.Game
  alias Bulls.GameServer

  def join("game:lobby", _msg, socket) do
    {:ok, socket}
  end

  def join("game:" <> gamename, %{"username" => username}, socket) do
    # might need something else here?
    # Is this idempotent, will I get the existing server?
    socket = socket
             |> assign(:game_name, gamename)
             |> assign(:user_name, username)
             |> assign(:type, :observer)
    #    IO.inspect("game: #{Kernel.inspect(GameServer.peek(gamename))}")
    GameServer.start(gamename)
    view =
      GameServer.register_observer(gamename, username)
      |> Game.view(username)
      |> Map.put(:type, :observer)
      |> Map.put(:game, gamename)
      |> Map.put(:user, username)
    IO.puts("gamename: #{gamename}")
    IO.puts("socket time")
    {:ok, socket}
  end

  def handle_in("info", %{"username" => username}, socket) do
    game = socket.assigns[:game_name]
    # IO.puts("gamename: #{game}")
    view = GameServer.peek(game)
           |> Game.view(username)
           |> Map.put(:type, :observer)
           |> Map.put(:game, game)
           |> Map.put(:user, username)
    {:reply, {:ok, view}, socket}
  end

  def handle_in("guess", payload, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    type = socket.assigns[:type] # May not be necessary as should always be player

    # this needs to change to use genserver
    game = Bulls.GameServer.guess(game, user, payload)
    socket = assign(socket, :game, game)

    view = Bulls.Game.view(game, user)
           |> Map.put(:type, type)
    # FIXME: Include player name and game name again
    {:reply, {:ok, view}, socket}
  end

  def handle_in("logout", _, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    old_state = GameServer.peek(game)
    GameServer.deregister_player(game, user)
    view = GameServer.deregister_observer(game, user)
           |> Game.view(user)
           |> Map.put(:type, :none)
           |> Map.put(:game, "")
           |> Map.put(:user, "")
    # this handler might need more logic. unsure rn.
    socket = socket
             |> assign(:game, "")
             |> assign(:user, "")
             |> assign(:type, :none)

    {:reply, {:ok, view}, socket}
  end

  # FIXME: Currently players that enter become observers, technically they should just be immediately required to choose.
  #   That being said, I am not certain I care as the logic is almost certainly more costly than the points
  def handle_in("join_game", %{"username" => user_name, "game" => game_name}, socket) do
    GameServer.start(game_name) # Is this idempotent, will I get the existing server?
    socket = socket
             |> assign(:game_name, game_name)
             |> assign(:user_name, user_name)
             |> assign(:type, :observer)
    view = GameServer.peek(game_name)
           |> GameServer.register_player(user_name)
           |> Game.view(user_name)
           |> Map.put(:type, :observer)
           |> Map.put(:game, game_name)
           |> Map.put(:user, user_name)

    {:reply, {:ok, view}, socket}
  end

  def handle_in("become_player", _, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    game_state = GameServer.peek(game)
    if Game.game_running?(game_state) do
      {:error, %{reason: "Cannot become a player during a game"}}
    else
      socket = assign(socket, :type, :player)
      GameServer.register_player(game, user)
      view = GameServer.deregister_observer(game, user)
             |> Game.view(user)
             |> Map.put(:type, :player)
             |> Map.put(:game, game)
             |> Map.put(:user, user)

      {:reply, {:ok, view}, socket}
    end
  end

  def handle_in("become_observer", _, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    game_state = GameServer.peek(game)
    if Game.game_running?(game_state) do
      {:reply, {:error, %{reason: "Cannot become observer during a game"}}, socket}
    else
      socket = assign(socket, :type, :observer)
      GameServer.deregister_player(game, user)
      view = GameServer.register_observer(game, user)
             |> Game.view(user)
             |> Map.put(:type, :observer)
             |> Map.put(:game, game)
             |> Map.put(:user, user)

      {:reply, {:ok, view}, socket}
    end
  end

  def handle_in("toggle_ready", _, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    type = socket.assigns[:type]
    game_state = GameServer.toggle_ready(game, user)
    # start game if all players ready. somehow kick off 30 second timer and enable guessing!
    game_state = if Game.players_ready?(game_state), do: GameServer.start_game(game), else: game_state

    view = Game.view(game_state, user)
           |> Map.put(:type, type)
           |> Map.put(:game, game)
           |> Map.put(:user, user)

    broadcast(socket, "update", game_state)
    {:reply, {:ok, view}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  intercept ["update", "update_all"]

  @impl true
  def handle_out("update", game, socket) do
    name = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    type = socket.assigns[:type]

    if type == :observer do
      view = Game.view(game)
             |> Map.put(:type, type)
             |> Map.put(:game, name)
             |> Map.put(:user, user)
      push(socket, "update", view)
      {:noreply, socket}
    else
      view = Game.view(game, user)
             |> Map.put(:type, type)
             |> Map.put(:game, name)
             |> Map.put(:user, user)
      push(socket, "update", view)
      {:noreply, socket}
    end
  end

  def handle_out("update_all", game, socket) do
    name = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    type = socket.assigns[:type]

    view = Game.view(game)
           |> Map.put(:type, type)
           |> Map.put(:game, name)
           |> Map.put(:user, user)
    IO.puts("Sending to:" <> user)
    IO.puts(Kernel.inspect(view))
    push(socket, "update", view)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
