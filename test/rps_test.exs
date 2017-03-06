defmodule RPSTest do
  use ExUnit.Case
  doctest RPS

  test "given a strategy, yield an action" do
    {index, seed} = RPS.action_for_strategy([0.4, 0.3, 0.3])
    correct = cond do
      seed <= 0.4 ->
        index == 0
      seed <= 0.7 ->
        index == 1
      seed <= 1.0 ->
        index == 2
    end
    assert correct
  end

  test "given distribution, choose action for seed value" do
    dist = [0.4, 0.7, 1.0]

    assert RPS.choose_action_with_index(dist, 0.4) == {0, 0.4}
    assert RPS.choose_action_with_index(dist, 0.7) == {1, 0.7}
    assert RPS.choose_action_with_index(dist, 0.8) == {2, 0.8}
  end

  test "given accumulated regrets, yield strategy" do
    assert RPS.strategy_for_regrets([3, 1, 4]) == [3/8, 1/8, 4/8]
  end

  test "compute regret of first action in light of second action" do
    # [rock, paper, scissors]
    # [0, 1, 2]
    assert RPS.regrets_for_action(RPS.rock, RPS.paper) ==    [0,  1,  2]
    assert RPS.regrets_for_action(RPS.rock, RPS.rock) ==     [0,  1, -1]
    assert RPS.regrets_for_action(RPS.rock, RPS.scissors) == [0, -2, -1]

    assert RPS.regrets_for_action(RPS.paper, RPS.rock) ==     [-1, 0, -2]
    assert RPS.regrets_for_action(RPS.paper, RPS.paper) ==    [-1, 0,  1]
    assert RPS.regrets_for_action(RPS.paper, RPS.scissors) == [ 2, 0,  1]

    assert RPS.regrets_for_action(RPS.scissors, RPS.rock) ==     [ 1,  2, 0]
    assert RPS.regrets_for_action(RPS.scissors, RPS.scissors) == [ 1, -1, 0]
    assert RPS.regrets_for_action(RPS.scissors, RPS.paper) ==    [-2, -1, 0]
  end

  test "sums continuous regrets over manual plays" do
    regrets = RPS.compute_play(RPS.rock, RPS.paper) #
    assert regrets == [0,  1,  2]

    regrets = RPS.compute_play(RPS.rock, RPS.rock, regrets)
    assert regrets == [0,  2, 1]

    regrets = RPS.compute_play(RPS.rock, RPS.scissors, regrets)
    assert regrets == [0, 0, 0]
  end

  @tag :skip
  test "choose an action based on the cumulative regret" do
    {action, regrets, seed} = RPS.play([0, 0, 0])
  end
end
