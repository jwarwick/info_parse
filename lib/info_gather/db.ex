defmodule InfoGather.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def url do
    do_url(System.get_env("DATABASE_URL"))
  end

  defp do_url(nil) do
    user = case System.get_env("USER") do
      nil -> "postgres"
      x -> x
    end
    "ecto://#{user}@localhost/infogather"
  end

  # Sample DATABASE_URL from Heroku
  # postgres://user3123:passkja83kd8@ec2-117-21-174-214.compute-1.amazonaws.com:6212/db982398
  defp do_url(x), do: String.replace(x, %r{^postgres}, "ecto")

end

defmodule InfoGather.DataModel do
  use Ecto.Model

  queryable "data" do
    field :entry, :string    
    field :created, :datetime
  end
end

defmodule InfoGather.ClassroomModel do
  use Ecto.Model

  queryable "classroom" do
    field :grade_level, :integer
    field :name, :string
  end
end

defmodule InfoGather.BusModel do
  use Ecto.Model

  queryable "bus" do
    field :name, :string
  end
end

