defmodule MinifiedListDiff do

  def diff(list1, list2) do
    case do_diff(list1, list2, nil) do
      :ok -> :ok
      nil -> nil
      new_elem ->
        case Enum.find_index(list2, fn(x) -> x == new_elem end) do
          nil   -> { :left, Enum.find_index(list1, fn(x) -> x == new_elem end), new_elem }
          index -> { :right, index, new_elem }
        end
    end
  end

  defp do_diff([head | tail1], [head | tail2], acc), do: do_diff(tail1, tail2, acc)
  defp do_diff([head, _ | tail1], [b1, head | tail2], _), do: do_diff(tail1, tail2, {b1})
  defp do_diff([a1, head | tail1], [head, _ | tail2], _), do: do_diff(tail1, tail2, {a1})
  defp do_diff([head | []], [head | []], acc), do: acc
  defp do_diff([head | []], [], nil), do: head
  defp do_diff([], [head | []], nil), do: head
  defp do_diff([],[],nil), do: :ok
  defp do_diff(_,_,_), do: nil
end
