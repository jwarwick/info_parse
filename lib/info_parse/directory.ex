defmodule InfoParse.Directory do
  @moduledoc """
  Create a directory of students/parents/addresses
  """

  import Ecto.Query

  def import_data do
    data = all_data
  end

  def all_data do
    query = from d in InfoGather.DataModel, select: d.entry
    data = InfoGather.Repo.all(query)
      # |> Enum.map(&(String.rstrip(&1, ?+)))
      |> Enum.map(&(String.split(&1, "&")))
      |> Enum.map(&(Enum.reverse(&1)))

      IO.inspect data
  end
end
