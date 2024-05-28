defmodule SwaiEdge.MixProject do
  use Mix.Project

  def project do
    [
      app: :swai_edge,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # ExDoc
      name: "Swai Edge",
      source_url: "https://github.com/beam-campus/swai/system/apps/swai_edge",
      homepage_url: "https://swarm-wars.ai",
      docs: [
        main: "Swai Edge",
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
      {:swai_core, in_umbrella: true},
      {:apis, in_umbrella: true}
    ]
  end
end
