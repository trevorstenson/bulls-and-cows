defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias Bulls.Game
  alias Bulls.GameServer


  def handle_in("guess", payload, socket) do
    game = socket.assigns[:game]
    user = socket.assigns[:user]
    type = socket.assigns[:type] # May not be necessary as should always be player

    game = Bulls.Game.guess(game, user, payload)
    socket = assign(socket, :game, game)

    view = Bulls.Game.view(game, user)
           |> Map.put(:type, type)
    {:reply, {:ok, view}, socket}
  end

  def handle_in("logout", _, socket) do
    socket = assign(:game, "")
             |> assign(:user, "")

    {:reply, {:ok, %{}}, socket}
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
           |> Game.view(user_name)
           |> Map.put(:type, :observer)

    {:reply, {:ok, view}, socket}
  end

  def handle_in("become_player", _, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]

    if Game.game_running?(game) do
      {:error, %{reason: "Cannot become a player during a game"}}
    else
      view = GameServer.peek(game)
             |> Game.register_player(user)
             |> Game.view(user)
             |> Map.put(:type, :player)


      socket = socket.assign(:type, :player)


      {:reply, {:ok, view}, socket}
    end
  end

  def handle_in("become_observer", _, socket) do
    game = socket.assigns[:game_name]
    user = socket.assigns[:user_name]

    if Game.game_running?(game) do
      {:error, %{reason: "Cannot become an observer during a game"}}
    else
      view = GameServer.peek(game)
             |> Game.deregister_player(user)
             |> Game.view(user)
             |> Map.put(:type, :observer)

      socket = socket.assign(:type, :observer)

      {:reply, {:ok, view}, socket}
    end
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

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
