defmodule InfoParse.Import do
  @moduledoc """
  Import directory information and populate database tables
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
    {parents, children} = partition_parents(not_notes)

    parents = chunks_by_number(parents)
    parents = lc p inlist parents do
      p
        |> Enum.concat(notes)
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

    child_ids = Enum.map(children, &add_student(&1))
      |> Enum.filter(fn(x) -> x end)
    
    parent_address_ids = Enum.map(parents, &add_parent(&1))
      |> Enum.filter(fn(x) -> x end)
    parent_ids = Enum.reduce parent_address_ids, [], fn ({pid, _}, acc) -> [pid | acc] end

    Enum.reduce parent_address_ids, nil, &update_address_id(&1, &2)
      

    lc c inlist child_ids, p inlist parent_ids, do: add_student_parent(c, p)

    IO.puts "Parents:"
    IO.inspect parents
    IO.inspect parent_ids

    IO.puts "Children:"
    IO.inspect children
    IO.inspect child_ids

  end

  defp add_student(c) do
    if 0 == String.length(c[:firstname]) && 0 == String.length(c[:lastname]) do
      nil
    else
      student = InfoGather.StudentModel.new(firstname: c[:firstname],
        lastname: c[:lastname], classroom_id: c[:classroom], bus_id: c[:bus])
      student = InfoGather.Repo.create(student)
      student.primary_key
    end
  end

  defp add_parent(p) do
    if 0 == String.length(p[:"parent-firstname"]) && 0 == String.length(p[:"parent-lastname"]) do
      nil
    else
      address_id = if p[:"parent-addr1"] do
        address = InfoGather.AddressModel.new(phone: p[:"parent-tel"],
          address1: p[:"parent-addr1"], address2: p[:"parent-addr2"], 
          city: p[:"parent-city"], state: p[:"parent-state"], zip: p[:"parent-zip"])
        address = InfoGather.Repo.create(address)
        address.primary_key
      end

      parent = InfoGather.ParentModel.new(firstname: p[:"parent-firstname"],
        lastname: p[:"parent-lastname"], email: p[:"parent-email"], phone: p[:"parent-mobile"],
        address_id: address_id, notes: p[:notes])
      parent = InfoGather.Repo.create(parent)
      {parent.primary_key, address_id}
    end
  end

  defp add_student_parent(s, p) do
    sp = InfoGather.StudentParentModel.new(student_id: s, parent_id: p)
    InfoGather.Repo.create(sp)
  end

  defp update_address_id({pid, nil}, last_addr_id) do
    query = from p in InfoGather.ParentModel, where: p.id == ^pid
    [parent] = InfoGather.Repo.all(query)
    parent = parent.address_id(last_addr_id)
    InfoGather.Repo.update(parent)
    last_addr_id
  end
  defp update_address_id({_pid, addr_id}, _last_addr_id), do: addr_id

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
    result = String.to_integer(v)
    case result do 
      {i, _rest} -> {k, i}
      :error -> {k, nil}
    end
  end
  defp make_reference(x), do: x

  defp decode_element({k, v}) do
    stripped = strip_key(k)
    {stripped, cleanup_value(v) |> key_specific_cleanup(stripped)}
  end

  defp cleanup_value(v) do
    v 
      |> URI.decode 
      |> String.strip 
  end


  defp key_specific_cleanup(v, k) when k in ["parent-addr1", "parent-addr2"] do
    v
      |> String.replace("Street", "St")
      |> String.replace("Road", "Rd")
      |> String.replace("Rd.", "Rd")
      |> String.replace("St.", "St")
  end

  defp key_specific_cleanup(v, k) when k in ["parent-mobile", "parent-tel"] do
    v = String.replace(v, ".", "-")
    if 10 == String.length(v) do
      a = String.slice(v, 0, 3)
      b = String.slice(v, 3, 3)
      c = String.slice(v, 6, 4)
      v = Enum.join [a, b, c], "-"
    end
    v
  end

  defp key_specific_cleanup(v, _k), do: v

  defp make_atom({k, v}), do: {binary_to_atom(k), v}

  defp strip_key(key), do: String.replace(key, %r/-[0-9]+$/, "")

  defp tupleize([a, b]), do: {a, b}

end
