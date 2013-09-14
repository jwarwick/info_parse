defmodule Mix.Tasks.Db.Drop do
  use Mix.Task
  alias Ecto.Adapters.Postgres

  require InfoGather.Repo

  @shortdoc "Drop required database tables"

  @moduledoc """
  Drops the needed postgres tables (students, parents, address)."
  """
  def run(args) do
    Mix.shell.info "Drop database tables..."
    Mix.Task.run "app.start", args
    queries = 
      [
       "DROP TABLE student",
       "DROP TABLE parent",
       "DROP TABLE address",
       "DROP TABLE student_parent",
      ]
    Enum.each queries, fn(sql) ->
      Mix.shell.info "Executing: #{sql}"
      result = Postgres.query(InfoGather.Repo, sql)
      IO.inspect result
    end
  end
end

