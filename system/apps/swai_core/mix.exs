defmodule SwaiCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :swai_core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # ExDoc
      name: "Swai Core Library",
      source_url: "https://github.com/beam-campus/swai/system/apps/swai_core",
      homepage_url: "https://DisComCo.pl",
      docs: [
        main: "Swai Core Library",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Swai.Core.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  # Specifies which paths to compile per environment.
  # defp elixirc_paths(:test), do: ["lib", "test/support"]
  # defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.1.3"},
      {:ecto, "~> 3.11.2"},
      {:uuid, "~> 1.1.8"},
      {:jason, "~> 1.4.1"},
      {:req, "~> 0.4.14"},
      {:hackney, "~> 1.20.1"},
      {:dialyze, "~> 0.2.0", only: [:dev]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: [:dev], runtime: false},
      {:mnemonic_slugs, "~> 0.0.3"},
    ]
  end
end
