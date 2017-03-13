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

  def opponent_action do
    {action, seed} = [0.4, 0.3, 0.3] |> action_for_strategy
    action
  end

  def play(
    times \\ 0,
    regrets \\ List.duplicate(0, 3),
    action_history \\ List.duplicate(0, 3),
    strategy_sum \\ List.duplicate(0, 3)
  ) when is_list(regrets) do
    cond do
      times > 0 ->
        strategy = regrets |> strategy_for_regrets

        {our_action, seed} = strategy
          |> strategy_for_regrets
          |> action_for_strategy

        new_regrets = our_action
          |> (fn(a) -> regrets_for_action(a, opponent_action) end).()
          |> (fn(r) -> elementwise_sum(r, regrets) end).()

        play(
           times - 1,
           new_regrets,
           action_history ++ [our_action],
           elementwise_sum(strategy_sum, strategy)
        )

      true -> {regrets, action_history, strategy_sum}
    end
  end

  def elementwise_sum(list1, list2) do
    for i <- 0..(length(list1)-1), do: Enum.at(list1, i) + Enum.at(list2, i)
  end

  def regrets_for_action(our_action, opponent_action) do
    values = for option <- 0..(@actions_count-1), do: value_for_action(option, opponent_action)
    experienced = Enum.at(values, our_action)
    Enum.map(values, fn(val) -> val - experienced end)
  end

  def average_strategy(strategy_sum) when is_list(strategy_sum) do
    sum = strategy_sum |> Enum.sum

    if sum > 0 do
      Enum.map(strategy_sum, fn(x) -> if x > 0, do: x/sum, else: 0 end)
    else
      List.duplicate(1/length(strategy_sum), length(strategy_sum))
    end
  end

  # aka, "normalize list based on sum"
  def strategy_for_regrets(regrets) when is_list(regrets) do
    sum = Enum.filter(regrets, fn(r) -> r > 0 end) |> Enum.sum

    if sum > 0 do
      Enum.map(regrets, fn(x) -> if x > 0, do: x/sum, else: 0 end)
    else
      List.duplicate(1/length(regrets), length(regrets))
    end
  end

  def action_for_strategy(strategy) when is_list(strategy) do
    strategy
      |> accumulate
      |> choose_action_with_index
  end

  def choose_action_with_index([ head | tail ], seed \\ :rand.uniform, count \\ 0) do
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

  def accumulate([], sum) do
    []
  end
end
