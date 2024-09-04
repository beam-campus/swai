defmodule Swai.CachesSystem do
  use GenServer

  @moduledoc """
  Swai.CachesSystem is a GenServer that manages the cache system.
  """

  require Logger

  require Cachex

  alias Caches

  @licenses_cache "/volume/caches/swai_licenses.cache"
  @hives_cache "/volume/caches/swai_hives.cache"
  @arenas_cache "/volume/caches/swai_arenas.cache"

  defp start_caches() do
    Logger.info("Starting caches")
    Caches.edges() |> Cachex.start()
    Caches.scapes() |> Cachex.start()
    # Caches.arenas() |> Cachex.start()
    Caches.hives() |> Cachex.start()
    Caches.licenses() |> Cachex.start()
    # Caches.swarms() |> Cachex.start()
    # Caches.particles() |> Cachex.start()
  end

  ################## CALLBACKS ############
  @impl GenServer
  def init(opts) do
    start_caches()

    children = [
      Edges.Service,
      Scapes.Service,
      {Licenses.Service, %{cache_file: @licenses_cache}},
      {Hives.Service, %{cache_file: @hives_cache}}
      #  {Arenas.Service, %{cache_file: @arenas_cache}}
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
