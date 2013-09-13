defmodule InfoParse.Directory do
  @moduledoc """
  Create a directory of students/parents/addresses
  """

  import Ecto.Query

  def import_data do
    data = parse_all
  end

  def parse_all do
    query = from(d in InfoGather.DataModel, select: d.entry)
    data = InfoGather.Repo.all(query)
      |> Enum.map(&(parse_one(&1)))

  end

  def parse_one(entry) do
    IO.puts "Parsing:"
    result = entry
      |> String.split("&")
      |> Enum.reverse()
      |> Enum.map(&(String.split(&1, "=")))
      |> Enum.map(&tupleize(&1))

    IO.inspect result
    
    {notes, not_notes} = partition_notes(result)
    notes = Enum.map(notes, &decode_element(&1))
    IO.puts "Notes:"
    IO.inspect notes

    {parents, children} = partition_parents(not_notes)
    parents = chunks_by_number(parents)
    parents = lc p inlist parents, do: Enum.map(p, &decode_element(&1))

    children = chunks_by_number(children)
    children = lc c inlist children, do: Enum.map(c, &decode_element(&1))
    children = lc c inlist children, do: Enum.map(c, &make_reference(&1))

    IO.puts "Parents:"
    IO.inspect parents

    IO.puts "Children:"
    IO.inspect children
  end

  # assumes list is ordered (ie [{a1, v}, {b1, v}, {a2, v}, {b2, v}]
  defp chunks_by_number(list) do
    Enum.chunks_by(list, fn({k, _v}) -> String.last(k) end)
  end

  defp partition_notes(list) do
    Enum.partition(list, fn({k, _v}) -> k == "notes" end)
  end

  defp partition_parents(list) do
    Enum.partition(list, fn({k, _v}) -> String.starts_with?(k, "parent") end)
  end

  defp make_reference({k, v}) when k in ["classroom", "bus"] do
    {i, _rest} = String.to_integer(v)
    {k, i}
  end
  defp make_reference(x), do: x

  defp decode_element({k, v}) do
    {strip_key(k), cleanup_value(v)}
  end

  defp cleanup_value(v) do
    v 
      |> URI.decode 
      |> String.strip 
      |> String.replace("Street", "St")
      |> String.replace("Road", "Rd")
  end

  defp strip_key(key), do: String.replace(key, %r/-[0-9]+$/, "")

  defp tupleize([a, b]), do: {a, b}

end
