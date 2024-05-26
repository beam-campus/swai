defmodule LogatronEdge.MixProject do
  use Mix.Project

  def project do
    [
      app: :logatron_edge,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # ExDoc
      name: "Logatron Edge",
      source_url: "https://github.com/beam-campus/logatron/system/apps/logatron_edge",
      homepage_url: "https://DisComCo.pl",
      docs: [
        main: "Logatron Edge",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Edge.Application, []},
      extra_applications: [:logger, :runtime_tools, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:slipstream, "~>1.1.0"},
      {:logatron_core, in_umbrella: true},
      {:apis, in_umbrella: true}
    ]
  end
end
