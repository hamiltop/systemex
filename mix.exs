defmodule Systemex.Mixfile do
  use Mix.Project

  def project do
    [app: :systemex,
     version: "0.0.2",
     #elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :cowboy, :os_mon, :bullet, :poison, :streamz],
     mod: {Systemex, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:exrm, "~> 0.14.7"},
      {:cowboy, "~> 1.0.0", override: true},
      {:poison, "~> 1.1.1"},
      {:bullet, github: "extend/bullet"},
      {:streamz, github: "hamiltop/streamz", branch: "event_source_protocol"}
    ]
  end
end
