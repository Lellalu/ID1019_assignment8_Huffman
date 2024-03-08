defmodule Minheap do
  def new() do
    []
  end

  def push([], {tree, freq}) do
    [{tree, freq}]
  end
  def push([{ta, fa} | rest], {tb, fb}) do
    cond do
      fb < fa -> [{tb, fb}, {ta, fa} | rest]
      true -> [{ta, fa}] ++ push(rest, {tb, fb})
    end
  end

  def pop([]) do
    {nil, []}
  end
  def pop([{tree, freq} | rest]) do
    {{tree, freq}, rest}
  end

  def len(minHeap) do
    length(minHeap)
  end
end
