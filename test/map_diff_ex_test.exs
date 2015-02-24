defmodule MapDiffExTest do
  use ExUnit.Case

  import MapDiffEx, only: [diff: 2,
                           diff: 3,
                           strip_prefix_from_string_list: 2
                          ]

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

    expected_diff = %{a: {1, 2}, b: {"test", "foobar"}, c: {0, :key_not_set}, "d": {:a, :x}}

    assert diff(map1, map2) == expected_diff
  end

  test "should ignore certain differences if given as option" do
    map1 = %{a: 1, b: "test"}
    map2 = %{a: 2, b: "foobar"}

    expected_diff = %{a: {1,2}}

    assert diff(map1, map2, %{ignore: ["b"]}) == expected_diff
  end

  test "should support nested keys for the ignore option" do
    map1 = %{a: 1, b: %{ x: "test", y: 1}}
    map2 = %{a: 2, b: %{ x: "foobar", y: 2}}

    expected_diff = %{a: {1,2}, b: %{y: {1,2}}}

    assert diff(map1, map2, %{ignore: ["b.x"]}) == expected_diff
  end

  test "should support nested keys with arrays for the ignore option" do
    map1 = %{a: 1, b: [%{ x: "test", y: 1}]}
    map2 = %{a: 2, b: [%{ x: "foobar", y: 2}]}

    expected_diff = %{a: {1,2}, b: [%{y: {1,2}}]}

    assert diff(map1, map2, %{ignore: ["b.x"]}) == expected_diff
  end

  test "should also detect missing keys in the first hash" do
    map2 = %{a: 1, b: "test", c: 0, "d": :a}
    map1 = %{a: 2, b: "foobar", "d": :x}

    expected_diff = %{a: {2, 1}, b: {"foobar", "test"}, c: {:key_not_set, 0}, "d": {:x, :a}}

    assert diff(map1, map2) == expected_diff
  end

  test "should detect the difference between nil value and missing key" do
    map1 = %{a: 1}
    map2 = %{a: 1, b: nil}

    expected_diff = %{b: {:key_not_set, nil}}
    assert diff(map1, map2) == expected_diff
  end

  test "should handle sub maps" do
    map1 = %{a: %{b: 2}}
    map2 = %{a: %{b: 3}}

    expected_diff = %{a: %{b: {2,3}}}

    assert diff(map1, map2) == expected_diff
  end

  test "should handle lists with same length" do
    map1 = %{a: [1,2]}
    map2 = %{a: [2,3]}

    expected_diff = %{a: [{1,2},{2,3}]}

    assert diff(map1, map2) == expected_diff
  end

  test "should handle different order in list as special case" do
    map1 = %{a: [1,2]}
    map2 = %{a: [2,1]}

    expected_diff = %{a: {"List with order: 0,1", "List with order: 1,0"}}

    assert diff(map1, map2) == expected_diff
  end

  test "should handle lists with different length" do
    map1 = %{a: [1,2]}
    map2 = %{a: [2,3,4]}

    expected_diff = %{a: {[1,2],[2,3,4]}}

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

  test "should compare maps as list elements with empty list" do
    map1 = %{key: [%{a: 1, b: "test", c: 0, "d": :a}]}
    map2 = %{key: []}

    expected_diff = %{key: {[%{a: 1, b: "test", c: 0, "d": :a}],[]}}

    assert diff(map1, map2) == expected_diff
  end

  test "should compare maps as list elements" do
    map1 = %{key: [%{a: 1, b: "test", c: 0, "d": :a}]}
    map2 = %{key: [%{a: 1, b: "test", c: 1, "d": :a}]}

    expected_diff = %{key: [%{c: {0,1}}]}

    assert diff(map1, map2) == expected_diff
  end

  test ".strip_prefix_from_string_list should strip prefix from keys" do
    assert strip_prefix_from_string_list(["foo.bar"], :foo) == ["bar"]
  end

  test ".strip_prefix_from_string_list should omit keys not matching the key" do
    assert strip_prefix_from_string_list(["other.bar"], :foo) == []
  end

end
