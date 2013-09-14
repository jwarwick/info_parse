defmodule InfoGather.StudentModel do
  use Ecto.Model

  queryable "student" do
    field :firstname, :string    
    field :lastname, :string    
    field :bus_id, :integer
    field :classroom_id, :integer
  end
end

defmodule InfoGather.ParentModel do
  use Ecto.Model

  queryable "parent" do
    field :firstname, :string    
    field :lastname, :string    
    field :email, :string    
    field :phone, :string    
    field :address_id, :integer
  end
end

defmodule InfoGather.AddressModel do
  use Ecto.Model

  queryable "address" do
    field :phone, :string    
    field :address1, :string    
    field :address2, :string    
    field :city, :string    
    field :state, :string    
  end
end
