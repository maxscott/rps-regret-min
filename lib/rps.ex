defmodule RPS do
  @moduledoc """
  Documentation for RPS.
  """

  # constants
  @rock 0
  @paper 1
  @scissors 2

  def rock, do: @rock
  def paper, do: @paper
  def scissors, do: @scissors

  # aka, "normalize list based on sum"
  def strategyForRegrets(regrets) when is_list(regrets) do
    sum = Enum.sum(regrets)
    Enum.map(regrets, fn(x) -> x/sum end)
  end

  def actionForStrategy(strategy) when is_list(strategy) do
    strategy
      |> accumulate
      |> chooseActionUniform
  end

  def chooseActionUniform(distribution) when is_list(distribution) do
    seed = :rand.uniform
    chooseActionWithIndex(distribution, seed)
  end

  def chooseActionWithIndex([ head | tail ], seed, count \\ 0) do
    if head >= seed do
      {count, seed}
    else
      chooseActionWithIndex(tail, seed, count+1)
    end
  end

  # [1, 2, 4, 6] --> [1, 3, 7, 13]
  # throwing a warning right now because of clauses and default values
  def accumulate([ head | tail ], sum \\ 0) do
    [ head + sum | accumulate(tail, head + sum) ]
  end
  def accumulate([], num) do [] end

end
