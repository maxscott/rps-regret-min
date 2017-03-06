defmodule RPSTest do
  use ExUnit.Case
  doctest RPS

  test "given a strategy, yield an action" do
    {index, seed} = RPS.actionForStrategy([0.4, 0.3, 0.3])
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

    assert RPS.chooseActionWithIndex(dist, 0.4) == {0, 0.4}
    assert RPS.chooseActionWithIndex(dist, 0.7) == {1, 0.7}
    assert RPS.chooseActionWithIndex(dist, 0.8) == {2, 0.8}
  end

  test "given accumulated regrets, yield strategy" do
    assert RPS.strategyForRegrets([3, 1, 4]) == [3/8, 1/8, 4/8]
  end

  @tag :skip
  test "compute regret of first action in light of second action" do
    # [rock, paper, scissors]
    # [0, 1, 2]
    assert RPS.regretForAction(RPS.rock, RPS.paper) == [0, 1, 2]
  end
end
