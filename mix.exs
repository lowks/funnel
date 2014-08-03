defmodule Funnel.Mixfile do
  use Mix.Project

  def project do
    [ app: :funnel,
      version: "0.0.1",
      compilers: [:elixir, :app],
      compile_path: "tmp/#{Mix.env}/funnel/ebin",
      elixir: "~> 0.15",
      description: description,
      package: package,
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:httpotion, :jsex],
      mod: { Funnel, [] } ]
  end

  defp deps do
    [ { :httpotion,   github: "myfreeweb/httpotion" },
      { :jsex,        "~> 2.0" },
      { :uuid,        github: "travis/erlang-uuid" },
      { :ex_doc,      github: "elixir-lang/ex_doc", only: [:dev] },
      { :poolboy,     "~> 1.2" }
    ]
  end

  defp description do
    """
    Streaming API built upon ElasticSearch's percolation.
    """
  end

  defp package do
    [ contributors: ["chatgris"],
      licenses: ["MIT"],
      links: [ { "Github", "https://github.com/af83/funnel" }]]
  end
end
