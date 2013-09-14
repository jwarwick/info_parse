defmodule Mix.Tasks.Db.Create do
  use Mix.Task
  alias Ecto.Adapters.Postgres

  require InfoGather.Repo

  @shortdoc "Create required database tables (doesn't populate them)"

  @moduledoc """
  Creates the needed postgres tables (students, parents, address). Doesn't populate them.
  """
  def run(args) do
    Mix.shell.info "Creating database tables..."
    Mix.Task.run "app.start", args
    Mix.Task.run "db.drop", args
    queries = 
      [
       "CREATE TABLE IF NOT EXISTS student (id serial PRIMARY KEY, firstname text, lastname text, bus_id integer, classroom_id integer)",
       "CREATE TABLE IF NOT EXISTS address (id serial PRIMARY KEY, phone text, address1 text, address2 text, city text, state text)",
       "CREATE TABLE IF NOT EXISTS parent (id serial PRIMARY KEY, firstname text, lastname text, email text, phone text, address_id integer, notes text)",
       "CREATE TABLE IF NOT EXISTS student_parent (id serial PRIMARY KEY, student_id integer, parent_id integer)"
      ]
    Enum.each queries, fn(sql) ->
      Mix.shell.info "Executing: #{sql}"
      result = Postgres.query(InfoGather.Repo, sql)
      IO.inspect result
    end
  end
end

