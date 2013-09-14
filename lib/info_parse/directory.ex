defmodule InfoParse.Directory do
  @moduledoc """
  Create a directory of students/parents/addresses
  """

  import Ecto.Query

  def import_data do
    parse_all
  end

  def parse_all do
    query = from(d in InfoGather.DataModel, select: d.entry)
    InfoGather.Repo.all(query)
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
    notes = 
      notes 
      |> Enum.map(&decode_element(&1))
      |> Enum.map(&make_atom(&1))

    IO.puts "Notes:"
    IO.inspect notes

    {parents, children} = partition_parents(not_notes)

    parents = chunks_by_number(parents)
    parents = lc p inlist parents do
      p
        |> Enum.map(&decode_element(&1))
        |> Enum.map(&make_atom(&1))
    end

    children = chunks_by_number(children)
    children = lc c inlist children do
      c
        |> Enum.map(&decode_element(&1))
        |> Enum.map(&make_reference(&1))
        |> Enum.map(&make_atom(&1))
    end

    child_ids = Enum.map children, &add_student(&1)
    parent_ids = Enum.map parents, &add_parent(&1)

    IO.puts "Parents:"
    IO.inspect parents
    IO.inspect parent_ids

    IO.puts "Children:"
    IO.inspect children
    IO.inspect child_ids

  end

  defp add_student(c) do
    student = InfoGather.StudentModel.new(firstname: c[:firstname],
      lastname: c[:lastname], classroom_id: c[:classroom], bus_id: c[:bus])
    student = InfoGather.Repo.create(student)
    student.primary_key
  end

  defp add_parent(p) do
    address_id = if p[:"parent-addr1"] do
      address = InfoGather.AddressModel.new(phone: p[:"parent-tel"],
        address1: p[:"parent-addr1"], address2: p[:"parent-addr2"], 
        city: p[:"parent-city"], state: p[:"parent-state"])
      address = InfoGather.Repo.create(address)
      address.primary_key
    end

    parent = InfoGather.ParentModel.new(firstname: p[:"parent-firstname"],
      lastname: p[:"parent-lastname"], email: p[:"parent-email"], phone: p[:"parent-mobile"],
        address_id: address_id)
    parent = InfoGather.Repo.create(parent)
    IO.puts "uploaded parent:"
    IO.inspect parent
    parent.primary_key
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

  defp make_atom({k, v}), do: {binary_to_atom(k), v}

  defp strip_key(key), do: String.replace(key, %r/-[0-9]+$/, "")

  defp tupleize([a, b]), do: {a, b}

end
