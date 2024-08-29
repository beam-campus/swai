defmodule Swai.CachesSystem do
  use GenServer

  @moduledoc """
  Swai.MngFarms.System is a GenServer that manages the MngFarms cache system.
  """

  require Logger

  require Cachex

  @swarm_licenses_cache "/tmp/swarm_licenses.cache"

  defp start_caches() do
    Logger.info("Starting caches")
    :edges_cache |> Cachex.start()
    :scapes_cache |> Cachex.start()
    # :workspaces_cache |> Cachex.start()
    :swarm_licenses_cache |> Cachex.start()
  end

  ################## CALLBACKS ############
  @impl GenServer
  def init(opts) do
    start_caches()

    children = [
      Edges.Service,
      Scapes.Service,
      # Workspaces.Service,
      {SwarmLicenses.Service, %{cache_file: @swarm_licenses_cache}}
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: :caches_system_supervisor
    )

    {:ok, opts}
  end

  ############### PLUMBING ################

  def child_spec(opts),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :permanent
    }

  def start_link(opts),
    do:
      GenServer.start_link(
        __MODULE__,
        opts,
        name: __MODULE__
      )
end
