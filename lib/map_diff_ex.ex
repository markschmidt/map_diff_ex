defmodule MapDiffEx do

  def diff(map1, map2), do: do_diff(map1, map2) |> filter_empty_map

  defp do_diff(map1, map2) when map1 == map2, do: nil
  defp do_diff(map1, map2) when is_map(map1) and is_map(map2) do
    Dict.keys(map1) ++ Dict.keys(map2)
    |> Enum.uniq
    |> Enum.map(fn key ->
      {key, do_diff(Dict.get(map1, key, :key_not_set), Dict.get(map2, key, :key_not_set))}
    end)
    |> filter_nil_values
    |> to_map
  end

  defp do_diff(list1, list2) when is_list(list1) and is_list(list2) do
    case length(list1) == length(list2) do
      false -> {list1, list2}
      true  -> (0..length(list1)-1)
               |> Enum.map(fn(i) ->
                 do_diff(Enum.at(list1, i), Enum.at(list2, i))
               end)
    end
  end

  defp do_diff(value1, value2) do
    {value1, value2}
  end

  defp to_map(list), do: Dict.merge(%{}, list)

  defp filter_nil_values(list) do
    list
    |> Enum.reject(fn({_key, value} -> is_nil(value)) end)
  end

  defp filter_empty_map(map) when map_size(map) == 0, do: nil
  defp filter_empty_map(map), do: map
end
