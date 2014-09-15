defmodule MapDiffEx do

  def diff(map1, map2), do: do_diff(map1, map2)

  defp do_diff(map1, map2) when map1 == map2, do: nil
  defp do_diff(map1, map2) when is_map(map1) and is_map(map2) do
    map1
    |> Map.keys
    |> Enum.concat(Map.keys(map2))
    |> Enum.map(fn key ->
      {key, do_diff(Map.get(map1, key), Map.get(map2, key))}
    end)
    |> to_map
  end

  defp do_diff(value1, value2) do
    {value1, value2}
  end


  defp to_map(list) do
    Dict.merge(%{}, list)
  end
end
