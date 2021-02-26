defmodule Bulls.GameServer do
  use GenServer

  alias Bulls.StateAgent
  alias Bulls.Game

  def reg(name) do
    {:via, Registry, {Bulls.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    Bulls.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = Bulls.StateAgent.get(name) || Bulls.Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def register_player(name, player) do
    GenServer.call(reg(name), {:register_player, name, player})
  end

  def deregister_player(name, player) do
    GenServer.call(reg(name), {:deregister_player, name, player})
  end

  def register_observer(name, player) do
    GenServer.call(reg(name), {:register_observer, name, player})
  end

  def deregister_observer(name, player) do
    GenServer.call(reg(name), {:deregister_observer, name, player})
  end

  def toggle_ready(name, player) do
    GenServer.call(reg(name), {:toggle_ready, name, player})
  end

  def start_game(name) do
    GenServer.call(reg(name), {:start_game})
  end

  def guess(name, username, guess) do
    GenServer.call(reg(name), {:guess, name, username, guess})
  end

  def next_turn(name) do
    GenServer.call(reg(name), {:next_turn, name})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:register_player, name, player}, _from, game) do
    game = Bulls.Game.register_player(game, player)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:deregister_player, name, player}, _from, game) do
    game = Bulls.Game.deregister_player(game, player)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:register_observer, name, player}, _from, game) do
    game = Bulls.Game.register_observer(game, player)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:deregister_observer, name, player}, _from, game) do
    game = Bulls.Game.deregister_observer(game, player)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:toggle_ready, name, player}, _from, game) do
    game = Bulls.Game.toggle_ready(game, player)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:start_game}, _from, game) do
    game = Bulls.Game.start_game(game)
    {:reply, game, game}
  end

  def handle_call({:guess, name, username, guess}, _from, game) do
    game = Bulls.Game.guess(game, username, guess)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:next_turn, name}, _from, game) do
    game = Bulls.Game.next_turn(game)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end
end
