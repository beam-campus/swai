defmodule Swai.CachesSystem do
  use GenServer

  @moduledoc """
  Swai.MngFarms.System is a GenServer that manages the MngFarms cache system.
  """

  require Logger

  require Cachex

  defp start_caches() do
    Logger.info("Starting caches")
    :edges_cache |> Cachex.start()
    :scapes_cache |> Cachex.start()
    :regions_cache |> Cachex.start()
    :farms_cache |> Cachex.start()
    :lives_cache |> Cachex.start()
    :nature_cache |> Cachex.start()
    :workspaces_cache |> Cachex.start()
    :swarm_trainings_cache |> Cachex.start()
  end

  ################## CALLBACKS ############
  @impl GenServer
  def init(opts) do
    start_caches()

    children = [
      Edges.Service,
      Scapes.Service,
      Regions.Service,
      Farms.Service,
      Lives.Service,
      Nature.Service,
      Workspaces.Service,
      SwarmTrainings.Service
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
