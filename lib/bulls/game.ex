defmodule Bulls.Game do
  def new do
    %{
      secret: random_secret(),
      players: %{},
      observers: MapSet.new(),
      running: false,
      guesses: MapSet.new(),
      turn: 1
    }
  end

  def register_player(state, username) do
    players = state[:players]
              |> Map.put(username, %{results: [], gameWon: false, errString: "", ready: false})
    %{state | players: players}
  end

  def deregister_player(state, username) do
    players = Map.delete(state[:players], username)
    %{state | players: players}
  end

  def register_observer(state, username) do
    observers = MapSet.put(state[:observers], username)
    %{state | observers: observers}
  end

  def deregister_observer(state, username) do
    observers = MapSet.delete(state[:observers], username)
    %{state | observers: observers}
  end

  def toggle_ready(state, username) do
    player = Map.get(state[:players], username)
    new_player = Map.put(player, :ready, !player[:ready])
    players = Map.put(state[:players], username, new_player)
    %{state | players: players}
  end

  def players_ready?(state) do
    players = Map.to_list(state[:players])

    Enum.all?(players, fn {x, y} -> y[:ready] end)
  end

  def game_running?(state) do
    state[:running]
  end

  def round_over?(state) do
    Enum.all?(state[:players], fn {x, y} ->
      Enum.count(y[:results]) == state[:turn]
    end)
  end

  def next_turn(state) do
    round_guesses = Enum.flat_map(state[:players], fn {key, player} ->
      Enum.map(player[:results], fn res ->
        Map.put(res, :user, key)
      end)
    end)
    %{state | turn: (state[:turn] + 1), guesses: MapSet.new(round_guesses)}
  end

  def start_game(state) do
    %{state | running: true}
  end

  # def view(state, username) do
  #   # return map + gameOver, or this shitty default map im using
  #   # so i dont have to add conditional checks to all the state in react
  #   # DONT HATE ME ILL FIX IT LATER
  #   view_state =
  #     cond do
  #       Map.has_key?(state[:players], username) -> Map.put(state[:players][username], :gameOver, state[:gameOver])
  #       true -> %{results: [], gameWon: false, errString: "", ready: false} # equivalent to new player array
  #     end
  #   Map.put(view_state, :running, state[:running])
  # end

  def view(state) do
    view = Map.delete(state, :secret)
    %{view | observers: MapSet.to_list(view[:observers]),  guesses: MapSet.to_list(view[:guesses])}
  end

  def guess(state, username, guess) do
    cond do
      guess == state[:secret] ->
        player = state[:players][username]
                 |> Map.replace(:gameWon, true) # Todo: Should we log the guess as well?
        Map.replace(state, :players, Map.replace(state[:players], username, player))

      !is_four(guess) ->
        player = state[:players][username]
                 |> Map.replace(:errString, "Guess must be a length of four.")
        Map.replace(state, :players, Map.replace(state[:players], username, player))

      !is_unique(guess) ->
        player = state[:players][username]
                 |> Map.replace(:errString, "Ensure your input is four unique digits.")
        Map.replace(state, :players, Map.replace(state[:players], username, player))

      is_four(guess) and is_unique(guess) -> calculate_match(state, username, guess)
    end
  end

  def calculate_match(state, username, guess) do
    guess_chars = String.codepoints(guess)
    place_matches = place_matches(guess_chars, state[:secret])
    value_matches = value_matches(guess_chars, state[:secret]) - place_matches

    player = state[:players][username]
    player = %{player | results: player[:results] ++ [%{turn: state[:turn], guess: guess, bulls: place_matches, cows: value_matches}]}

    players = Map.replace(state[:players], username, player)
    %{state | players: players}
  end

  def value_matches(chars, secret) do
    Enum.filter(chars, fn c -> String.contains?(secret, c) end)
    |> length
  end

  def place_matches(chars, secret) do
    chars
    |> Enum.with_index
    |> Enum.map(
         fn {c, i} ->
           [c, String.at(secret, i)]
         end
       )
    |> Enum.filter(
         fn [a, b] ->
           a == b
         end
       )
    |> length
  end

  def random_secret do
    Stream.repeatedly(fn -> :rand.uniform(10) end)
    |> Stream.uniq
    |> Enum.take(4)
    |> Enum.map(fn x -> x - 1 end)
    |> Enum.join("")
  end

  def is_four(guess) do
    String.length(guess) == 4
  end

  def is_unique(guess) do
    String.to_charlist(guess)
    |> Enum.uniq
    |> length
    |> Kernel.==(String.length(guess))
  end
end
