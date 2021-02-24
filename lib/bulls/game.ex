defmodule Bulls.Game do
  def new do
    %{
      secret: random_secret(),
      gameOver: false,
      players: %{},
    }
  end

  def register_player(state, username) do
    players = state[:players]
              |> Map.put(username, %{results: [], gameWon: false, errString: ""})

    %{state | players: players}
  end

  def view(state, username) do
    view = state[:players][username]
           |> Map.put(:gameOver, state[:gameOver])

    view
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
    player = %{player | results: player[:results] ++ [%{guess: guess, bulls: place_matches, cows: value_matches}]}

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
