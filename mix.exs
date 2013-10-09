defmodule InfoParse.Mixfile do
  use Mix.Project

  def project do
    [ app: :info_parse,
      version: "0.0.1",
      dynamos: [InfoParse.Dynamo],
      compilers: [:elixir, :dynamo, :app],
      env: [prod: [compile_path: "ebin"]],
      compile_path: "tmp/#{Mix.env}/info_parse/ebin",
      name: "Info Parser",
      source_url: "https://github.com/jwarwick/info_parse",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:cowboy, :dynamo],
      mod: { InfoParse, [] } ]
  end

  defp deps do
    [ 
      { :cowboy, github: "extend/cowboy" },
      { :dynamo, github: "elixir-lang/dynamo" },
      { :ecto, github: "elixir-lang/ecto" },
      { :pgsql, github: "semiocast/pgsql" },
      { :exjson, github: "guedes/exjson" },
      { :ex_doc, github: "elixir-lang/ex_doc" }
    ]
  end
end
