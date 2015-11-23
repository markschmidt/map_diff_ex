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

  test "should return nil when values are not equal but configured to be treated as the same" do
    map1 = %{key: [%{a: "", b: nil}]}
    map2 = %{key: [%{a: nil, b: "0000-00-00"}]}

    assert diff(map1, map2, %{treat_as_same: [{nil,""},{nil,"0000-00-00"}]}) == nil
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

  test "should collapse empty maps and lists correctly" do
    map1 = %{collection: [%{id: 1, work_experience: [%{normalized_name: "foobar"}]}]}
    map2 = %{collection: [%{id: 1, work_experience: [%{normalized_name: "foobar2"}]}]}

    assert diff(map1, map2, %{ignore: ["collection.work_experience.normalized_name"]}) == nil
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

  test "should ignore list order if option is given" do
    map1 = %{a: [1,2]}
    map2 = %{a: [2,1]}

    assert diff(map1, map2, %{ignore_list_order: true}) == nil
  end

  test "should report list which differ in only one element in a more readable way - rhs" do
    map1 = %{a: [1,2]}
    map2 = %{a: [1,2,3]}

    expected_diff = %{a: {"2 element List", {"List with additional element", 3}}}

    assert diff(map1, map2, %{minify_threshold: 0}) == expected_diff
  end

  test "should report list which differ in only one element in a more readable way - lhs" do
    map1 = %{a: [1,2,3]}
    map2 = %{a: [1,2]}

    expected_diff = %{a: {{"List with additional element", 3}, "2 element List"}}

    assert diff(map1, map2, %{minify_threshold: 0}) == expected_diff
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
