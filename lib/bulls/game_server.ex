defmodule Bulls.GameServer do
  use GenServer

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

  def guess(name, guess) do
    GenServer.call(reg(name), {:guess, name, guess})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:guess, name, guess}, _from, game) do
    game = Bulls.Game.guess(game, guess)
    Bulls.StateAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end
end
