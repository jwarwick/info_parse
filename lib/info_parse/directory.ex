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
    IO.puts "Notes:"
    IO.inspect notes

    {parents, children} = partition_parents(not_notes)
    IO.puts "Parents:"
    IO.inspect parents

    IO.puts "Children:"
    IO.inspect children
  end

  defp partition_notes(list) do
    Enum.partition(list, fn({k, _v}) -> k == "notes" end)
  end

  defp partition_parents(list) do
    Enum.partition(list, fn({k, _v}) -> String.starts_with?(k, "parent") end)
  end

  defp tupleize([a, b]), do: {a, b}

end
