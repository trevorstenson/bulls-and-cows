defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  @impl true
  def join("game:" <> _id, payload, socket) do
    if authorized?(payload) do
      game = Bulls.Game.new
      socket = assign(socket, :game, game)
      view = Bulls.Game.view(game)
      {:ok, view, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("guess", payload, socket) do
    old_game = socket.assigns[:game]
    new_game = Bulls.Game.guess(old_game, payload)
    socket = assign(socket, :game, new_game)
    view = Bulls.Game.view(new_game)
    {:reply, {:ok, view}, socket}
  end

  def handle_in("reset", _, socket) do
    new_game = Bulls.Game.new
    socket = assign(socket, :game, new_game)
    view = Bulls.Game.view(new_game)
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

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
