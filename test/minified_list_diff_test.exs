defmodule MinifiedListDiffTest do
  use ExUnit.Case

  import MinifiedListDiff, only: [diff: 2]

  test "should return :ok if the lists are the same" do
    assert diff([1,2,3], [1,2,3]) == :ok
  end

  test "should return nil if the lists can't be compared" do
    assert diff([1,2,3], [4,5,6]) == nil
  end

  test "should return a tuple with :right, index and added element if rhs is bigger" do
    assert diff([1,2], [1,2,3]) == {:right, 2, 3}
  end

  test "should return a tuple with :left, index and added element if lhs is bigger" do
    assert diff([1,2,3], [1,2]) == {:left, 2, 3}
  end
end

