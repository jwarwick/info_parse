defmodule InfoParse.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def url do
    do_url(System.get_env("DATABASE_URL"))
  end

  defp do_url(nil) do
    user = case System.get_env("USER") do
      nil -> "postgres"
      x -> x
    end
    "ecto://#{user}@localhost/infoparse"
  end

  # Sample DATABASE_URL from Heroku
  # postgres://user3123:passkja83kd8@ec2-117-21-174-214.compute-1.amazonaws.com:6212/db982398
  defp do_url(x), do: String.replace(x, %r{^postgres}, "ecto")

end

defmodule InfoParse.StudentModel do
  use Ecto.Model

  queryable "student" do
    field :firstname, :string    
    field :lastname, :string    
  end
end

defmodule InfoParse.ParentModel do
  use Ecto.Model

  queryable "parent" do
    field :firstname, :string    
    field :lastname, :string    
    field :email, :string    
    field :phone, :string    
  end
end

defmodule InfoParse.AddressModel do
  use Ecto.Model

  queryable "address" do
    field :phone, :string    
    field :address1, :string    
    field :address2, :string    
    field :city, :string    
    field :state, :string    
  end
end
