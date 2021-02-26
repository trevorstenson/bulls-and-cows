defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias Bulls.Game
  alias Bulls.GameServer

  def join("game:" <> gamename, %{"username" => username}, socket) do
    # might need something else here?
    # Is this idempotent, will I get the existing server?
    # socket = socket
    #          |> assign(:game_name, gamename)
    #          |> assign(:user_name, username)
    #          |> assign(:type, :observer)
    # GameServer.start(gamename)
    # view =
    #   GameServer.register_observer(gamename, username)
    #   |> Game.view
    #   |> Map.put(:type, :observer)
    #   |> Map.put(:game, gamename)
    #   |> Map.put(:user, username)


    socket = socket
             |> assign(:game_name, gamename)
             |> assign(:user_name, username)

    GameServer.start(gamename)

    game_state = GameServer.peek(gamename)
    cond do
      Enum.any?(game_state[:players], fn {x, y} -> x == username end) ->
        socket = assign(socket, :type, :player)
        IO.puts("hitting any case")
        {:ok, socket}
      true ->
        GameServer.register_observer(gamename, username)
        socket = assign(socket, :type, :observer)
        {:ok, socket}
    end
    IO.inspect("pls man: #{Kernel.inspect(game_state[:players])}")
    IO.inspect("#{username}")
    {:ok, socket}
  end

  def handle_in("info", %{"username" => username}, socket) do
    game = socket.assigns[:game_name]
    game_state = GameServer.peek(game)
    type = :observer

    cond do
      Enum.any?(game_state[:players], fn {x, y} ->
        IO.inspect("x: #{x}, y: #{Kernel.inspect(y)}, user: #{Kernel.inspect(y[:user])}, username: #{username}, result: #{x == username}")
        x == username
      end) ->
        socket = assign(socket, :type, :player)
        type = :player
        IO.puts("hitting any case")
        IO.inspect("socket ")
        view = GameServer.peek(game)
           |> Game.view
           |> Map.put(:type, type)
           |> Map.put(:game, game)
           |> Map.put(:user, username)
    {:reply, {:ok, view}, socket}
      true ->
        socket = assign(socket, :type, :observer)
        type = :observer
        IO.inspect("socket ")
        view = GameServer.peek(game)
           |> Game.view
           |> Map.put(:type, type)
           |> Map.put(:game, game)
           |> Map.put(:user, username)
    {:reply, {:ok, view}, socket}
    end

  end

  def handle_in("guess", payload, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    type = socket.assigns[:type] # May not be necessary as should always be player

    game_view = Bulls.GameServer.guess(game, user, payload)
    IO.inspect("game_view before cond: #{Kernel.inspect(game_view)}")
    winners = Enum.filter(game_view[:players], fn {x, y} -> y[:gameWon] end)
    |> Enum.map(fn {x, y} -> x end)
    cond do
        length(winners) > 0 ->
          broadcast(socket, "game_over", Map.put(game_view, :winners, winners))

        Bulls.Game.round_over?(game_view) ->
          game_view = Bulls.GameServer.next_turn(game)
          broadcast(socket, "update", game_view)
      true -> :ok
    end
    IO.inspect("game_view after cond: #{Kernel.inspect(game_view)}")
    view = Bulls.Game.view(game_view)
           |> Map.put(:type, type)
           |> Map.put(:game, game)
           |> Map.put(:user, user)
    {:reply, {:ok, view}, socket}
  end

  def handle_in("logout", _, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    view = GameServer.deregister_observer(game, user)
           |> Game.view
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
  # def handle_in("join_game", %{"username" => user_name, "game" => game_name}, socket) do
  #   GameServer.start(game_name) # Is this idempotent, will I get the existing server?
  #   socket = socket
  #            |> assign(:game_name, game_name)
  #            |> assign(:user_name, user_name)
  #   game_state = GameServer.peek(game_name)
  #   cond do
  #     Enum.any?(game_state[:players], fn {x, y} -> x == user_name end) ->
  #       game_state = Map.put(game_state, :type, :player)
  #       socket = assign(socket, :type, :player)
  #     true ->
  #       game_state = GameServer.register_observer(game_state, user_name) |> Map.put(:type, :observer)
  #       socket = assign(socket, :type, :observer)
  #   end
  #   IO.inspect("pls man: #{Kernel.inspect(game_state[:players])}")
  #   IO.inspect("#{user_name}")
  #   view = game_state
  #          |> Game.view
  #          |> Map.put(:game, game_name)
  #          |> Map.put(:user, user_name)

  #   {:reply, {:ok, view}, socket}
  # end

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
             |> Game.view
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
             |> Game.view
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

    view = Game.view(game_state)
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

  intercept ["update", "game_over"]

  @impl true
  @spec handle_out(<<_::48, _::_*24>>, map, Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_out("update", game, socket) do
    name = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    type = socket.assigns[:type]

    view = Game.view(game)
           |> Map.put(:type, type)
           |> Map.put(:game, name)
           |> Map.put(:user, user)
    push(socket, "update", view)
    {:noreply, socket}
  end

  def handle_out("game_over", game, socket) do
    name = socket.assigns[:game_name]
    user = socket.assigns[:user_name]
    type = socket.assigns[:type]

    view = Game.view(game)
           |> Map.put(:type, type)
           |> Map.put(:game, name)
           |> Map.put(:user, user)
           IO.inspect("just before sending: #{Kernel.inspect(view)}")
    push(socket, "update", view)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
