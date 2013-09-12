defmodule Mix.Tasks.Db.Create do
  use Mix.Task
  alias Ecto.Adapters.Postgres

  require InfoParse.Repo

  @shortdoc "Create required database tables (doesn't populate them)"

  @moduledoc """
  Creates the needed postgres tables (students, parents, address). Doesn't populate them.
  """
  def run(args) do
    Mix.shell.info "Creating database tables..."
    Mix.Task.run "app.start", args
    queries = 
      [
       "DROP TABLE student",
       "DROP TABLE parent",
       "DROP TABLE address",
       "CREATE TABLE IF NOT EXISTS student (id serial PRIMARY KEY, firstname text, lastname text)",
       "CREATE TABLE IF NOT EXISTS parent (id serial PRIMARY KEY, firstname text, lastname text, email text, phone text)",
       "CREATE TABLE IF NOT EXISTS address (id serial PRIMARY KEY, phone text, address1 text, address2 text, city text, state text)"
      ]
    Enum.each queries, fn(sql) ->
      Mix.shell.info "Executing: #{sql}"
      result = Postgres.query(InfoParse.Repo, sql)
      IO.inspect result
    end
  end
end

