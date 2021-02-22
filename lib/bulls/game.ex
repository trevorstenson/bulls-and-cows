defmodule Bulls.Game do
  def new do
    %{
      secret: random_secret(),
      results: [],
      remaining: 8,
      errString: "",
      gameWon: false
    }
  end

  def view(state) do
    Map.delete(state, :secret)
  end

  def guess(state, guess) do
    state = %{state | remaining: (state[:remaining] - 1)}
    cond do
      guess == state[:secret] -> %{state | gameWon: true}
      !is_four(guess) -> %{state | errString: "Guess must be a length of four."}
      !is_unique(guess) -> %{state | errString: "Ensure your input is four unique digits."}
      is_four(guess) and is_unique(guess) -> calculate_match(state, guess)
    end
  end

  def calculate_match(state, guess) do
    guess_chars = String.codepoints(guess)
    place_matches = place_matches(guess_chars, state[:secret])
    value_matches = value_matches(guess_chars, state[:secret]) - place_matches
    %{state | results: state[:results] ++ [%{guess: guess, bulls: place_matches, cows: value_matches}]}
  end

  def value_matches(chars, secret) do
    Enum.filter(chars, fn c -> String.contains?(secret, c) end) |> length
  end

  def place_matches(chars, secret) do
    chars
    |> Enum.with_index
    |> Enum.map(fn {c, i} ->
      [c, String.at(secret, i)]
    end)
    |> Enum.filter(fn [a, b] ->
      a == b
    end)
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
