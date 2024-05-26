defmodule Logatron.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  @moduledoc"""
  The main application module for Logatron.
  """

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    start_caches()

    children = [
      Logatron.Repo,
      {DNSCluster, query: Application.get_env(:logatron, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Logatron.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Logatron.Finch},
      Logatron.CachesSystem
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Logatron.Supervisor)
  end


  defp start_caches() do
    Logger.info("Starting caches")
    :edges_cache  |> Cachex.start()
    :scapes_cache |> Cachex.start()
    :regions_cache |> Cachex.start()
    :farms_cache |> Cachex.start()
    :lives_cache |> Cachex.start()
    :nature_cache |> Cachex.start()
  end





end
