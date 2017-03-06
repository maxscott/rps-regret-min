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

  def regrets_for_action(our_action, opponent_action) do
    temp = List.duplicate(0, @actions_count)

    cond do
      # all ties
      our_action == opponent_action ->
        temp = List.replace_at(temp, our_action-1, -1)
        List.replace_at(temp, our_action-@actions_count+1, +1)

      # all wins
      rem(our_action - opponent_action + 3, 3) == 1 ->
        temp = List.replace_at(temp, our_action-1, -1)
        List.replace_at(temp, our_action-@actions_count+1, -2)

      # all losses
      rem(opponent_action - our_action + 3, 3) == 1 ->
        temp = List.replace_at(temp, our_action-1, 2)
        List.replace_at(temp, our_action-@actions_count+1, 1)
    end

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
  # throwing a warning right now because of clauses and default values
  def accumulate([ head | tail ], sum \\ 0) do
    [ head + sum | accumulate(tail, head + sum) ]
  end
  def accumulate([], num) do [] end

end
