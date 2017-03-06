defmodule RPS do
  @moduledoc """
  Documentation for RPS.
  """

  # constants
  @rock 0
  @paper 1
  @scissors 2

  @actions_count 3

  def rock, do: @rock
  def paper, do: @paper
  def scissors, do: @scissors

  def value_for_action(our_action, opponent_action) do
    cond do
      # win
      our_action - opponent_action == 1 -> 1
      our_action - opponent_action == -2 -> 1

      # tie
      opponent_action == our_action -> 0

      # lose
      true -> -1
    end
  end

  def compute_play(our_action, opponent_action, old_regrets \\ List.duplicate(0, @actions_count)) do
    new_regrets = regrets_for_action(our_action, opponent_action)
    for i <- 0..(@actions_count-1), do: Enum.at(new_regrets, i) + Enum.at(old_regrets, i)
  end

  def regrets_for_action(our_action, opponent_action) do
    values = for option <- 0..(@actions_count-1), do: value_for_action(option, opponent_action)
    experienced = Enum.at(values, our_action)
    Enum.map(values, fn(val) -> val - experienced end)
  end

  # aka, "normalize list based on sum"
  def strategy_for_regrets(regrets) when is_list(regrets) do
    sum = Enum.sum(regrets)
    Enum.map(regrets, fn(x) -> x/sum end)
  end

  def action_for_strategy(strategy) when is_list(strategy) do
    strategy
      |> accumulate
      |> choose_action_uniform
  end

  def choose_action_uniform(distribution) when is_list(distribution) do
    seed = :rand.uniform
    choose_action_with_index(distribution, seed)
  end

  def choose_action_with_index([ head | tail ], seed, count \\ 0) do
    if head >= seed do
      {count, seed}
    else
      choose_action_with_index(tail, seed, count+1)
    end
  end

  # [1, 2, 4, 6] --> [1, 3, 7, 13]
  # TODO: get rid of warning
  def accumulate([ head | tail ], sum \\ 0) do
    [ head + sum | accumulate(tail, head + sum) ]
  end

  def accumulate([], _num) do [] end

end
