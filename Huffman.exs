defmodule Huffman do
  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end

  def text() do
    'this is some thing that we should encode'
  end

  def test do
    sample = sample()
    tree = tree(sample)
    encode = encode_table(tree)
    decode = decode_table(tree)
    text = text()
    seq = encode(text, encode)
    decode(seq, decode)
  end

  def tree(sample) do
    freq = freq(sample)
    huffman(freq)
  end

  def freq(sample) do
    freq(sample, Map.new())
  end
  def freq([], freq) do
    freq
  end
  def freq([char|rest], freq) do
    freq(rest, Map.put(freq, char, Map.get(freq, char, 0)+1))
  end

  def huffman(freq) do
    minHeap = Minheap.new()
    minHeap = Enum.reduce(freq, minHeap, fn {k, v}, acc ->
      Minheap.push(acc, {k, v})
    end)
    huffmanTree(minHeap)
  end
  def huffmanTree(minHeap) do
    cond do
      Minheap.len(minHeap) > 1 ->
        {{ta, fa}, minHeap} = Minheap.pop(minHeap)
        {{tb, fb}, minHeap} = Minheap.pop(minHeap)
        minHeap = Minheap.push(minHeap, {{ta, tb}, fa+fb})
        huffmanTree(minHeap)
      true ->
        {{tree, freq}, minHeap} = Minheap.pop(minHeap)
        tree
    end
  end

  def encode_table(tree) do
    encode_table(tree, Map.new(), [])
  end
  def encode_table({left, right}, encodeTable, path) do
    encodeTable = encode_table(left, encodeTable, path++[0])
    encodeTable = encode_table(right, encodeTable, path++[1])
    encodeTable
  end
  def encode_table(char, encodeTable, path) do
    Map.put(encodeTable, char, path)
  end

  def decode_table(tree) do
    encodeTable = encode_table(tree)
    Map.new(encodeTable, fn {key, val} -> {val, key} end)
  end

  def encode(text, table) do
    encode(text, table, [])
  end
  def encode([], table, acc) do
    acc
  end
  def encode([c | rest], table, acc) do
    encode(rest, table, acc ++ Map.get(table, c))
  end

  def decode(seq, table) do
    decode(seq, [], table, [])
  end
  def decode([], [], table, acc) do
    acc
  end
  def decode([], partialSeq, table, acc) do
    acc ++ [Map.get(table, partialSeq)]
  end
  def decode([bit | rest], partialSeq, table, acc) do
    cond do
      Map.has_key?(table, partialSeq) ->
        decode([bit | rest], [], table, acc++[Map.get(table, partialSeq)])
      true ->
        decode(rest, partialSeq++[bit], table, acc)
    end
  end

  def read(file) do
    text = File.read!(file)
    chars = String.to_charlist(text)
    {:ok, chars, String.length(text), Kernel.byte_size(text)}
  end

  def bench(n) do
    {_, chars, chars_len, _} = read("text.txt")
    tree = tree(chars)
    encode = encode_table(tree)
    decode = decode_table(tree)
    Enum.map(1..n, fn i ->
      sample_length = round(chars_len/n * i)
      sameple_chars = Enum.slice(chars, 0..sample_length)

      {encode_time, seq} = :timer.tc(Huffman, :encode, [sameple_chars, encode])
      {decode_time, _} = :timer.tc(Huffman, :decode, [seq, decode])
      IO.puts("Sample length: #{sample_length}")
      IO.puts("Encode time: #{encode_time}")
      IO.puts("Decode time: #{decode_time}")
      IO.puts("**********************************************")
    end)
    :ok
  end
end
