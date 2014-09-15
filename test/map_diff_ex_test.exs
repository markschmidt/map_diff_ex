defmodule MapDiffExTest do
  use ExUnit.Case

  import MapDiffEx, only: [diff: 2]

  test "should return nil for empty maps" do
    assert diff(%{}, %{}) == nil
  end

  test "should return nil for non-empty but equal maps" do
    map = %{a: 1, b: "test", "d": :a}
    assert diff(map, map) == nil
  end

  test "should return a map with all the diffs for keys which are different" do
    map1 = %{a: 1, b: "test", c: 0, "d": :a}
    map2 = %{a: 2, b: "foobar", "d": :x}

    expected_diff = %{a: {1, 2}, b: {"test", "foobar"}, c: {0, nil}, "d": {:a, :x}}

    assert diff(map1, map2) == expected_diff
  end

  test "should also detect missing keys in the first hash" do
    map2 = %{a: 1, b: "test", c: 0, "d": :a}
    map1 = %{a: 2, b: "foobar", "d": :x}

    expected_diff = %{a: {2, 1}, b: {"foobar", "test"}, c: {nil, 0}, "d": {:x, :a}}

    assert diff(map1, map2) == expected_diff
  end

  test "should handle sub maps" do
    map1 = %{a: %{b: 2}}
    map2 = %{a: %{b: 3}}

    expected_diff = %{a: %{b: {2,3}}}

    assert diff(map1, map2) == expected_diff
  end

  test "should handle lists" do
    map1 = %{a: [1,2]}
    map2 = %{a: [2,3]}

    expected_diff = %{a: {[1,2],[2,3]}}

    assert diff(map1, map2) == expected_diff
  end

  test "should be able to compare maps and list" do
    map1 = %{a: %{b: 2}}
    map2 = %{a: [2,3]}

    expected_diff = %{a: {%{b: 2}, [2,3]}}

    assert diff(map1, map2) == expected_diff
  end

  test "should be able to compare lists and maps" do
    map1 = %{a: [2,3]}
    map2 = %{a: %{b: 2}}

    expected_diff = %{a: {[2,3], %{b: 2}}}

    assert diff(map1, map2) == expected_diff
  end
end
