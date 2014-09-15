defmodule MapDiffEx do

  def diff(map1, map2), do: do_diff(map1, map2)

  defp do_diff(map1, map2) when map1 == map2, do: nil
  defp do_diff(map1, map2) when is_map(map1) and is_map(map2) do
    Map.keys(map1) ++ Map.keys(map2)
    |> Enum.uniq
    |> Enum.map(fn key ->
      {key, do_diff(Map.get(map1, key), Map.get(map2, key))}
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
end
