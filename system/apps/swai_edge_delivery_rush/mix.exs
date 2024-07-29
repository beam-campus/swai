defmodule DeliveryRush.MixProject do
  use Mix.Project

  def project do
    [
      app: :swai_edge_delivery_rush,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :apis],
      mod: {DeliveryRush.EdgeApp, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:slipstream, "~> 1.1.0"},
      {:swai_core, in_umbrella: true},
      {:apis, in_umbrella: true}
    ]
  end
end
