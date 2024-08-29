defmodule SwaiWeb.LicenseQueue do
  @moduledoc """
  The LicenseQueue is used to broadcast messages to all clients
  """
  use GenServer

  alias SwaiWeb.EdgeChannel
  alias Scape.Init, as: ScapeInit
  alias Edges.Service, as: Edges
  alias SwarmLicenses.Service, as: Licenses


  require Logger

  ################# INIT ##########################
  @impl true
  def init(_init_args \\ []) do
    Process.send_after(self(), :pop_queue, 1_000)
    {:ok, []}
  end

  defp try_start_scape(license) do
    case Edges.get_candidates_for_biotope(license.biotope_id) do
      [] ->
        "no candidates"

      edges ->
        the_edge =
          edges
          |> Enum.random()

        scape_init = %ScapeInit{
          id: UUID.uuid4(),
          biotope_id: license.biotope_id,
          biotope_name: license.biotope_name,
          image_url: license.image_url,
          tags: license.tags,
          license_id: license.license_id,
          edge_id: the_edge.id,
          user_id: license.user_id,
          algorithm_acronym: license.algorithm_acronym,
          algorithm_id: license.algorithm_id,
          algorithm_name: license.algorithm_name,
          dimensions: license.dimensions,
          swarm_id: license.swarm_id,
          swarm_name: license.swarm_name,
          swarm_size: license.swarm_size,
          swarm_time_min: license.swarm_time_min
        }

        Logger.warning("

        TRY STARTING SCAPE

          with SCAPE: #{inspect(scape_init)}

          on EDGE: #{inspect(the_edge)}

          ")

        EdgeChannel.start_scape(the_edge, scape_init)
    end
  end

  ################# POP_QUEUE #####################
  @impl true
  def handle_info(:pop_queue, state) do
    Process.send_after(self(), :pop_queue, 10_000)

    state =
      case Licenses.get_all_queued_or_paused() do
        [] ->
          state

        queued ->
          queued
          |> Enum.map(&try_start_scape/1)
          |> Enum.map(&Logger.info("\n\n Queued: #{inspect(&1)} \n\n"))
      end

    {:noreply, state}
  end

  #################### PLUMBING ###################
  def start_link(init_args) do
    GenServer.start_link(
      __MODULE__,
      init_args,
      name: __MODULE__
    )
  end

  def child_spec(init_args),
    do: %{
      id: __MODULE__,
      start: {
        __MODULE__,
        :start_link,
        [init_args]
      },
      type: :worker
    }

  def via(key),
    do: Swai.Registry.via_tuple({:scape_queue, to_name(key)})

  def via_sup(key),
    do: Swai.Registry.via_tuple({:scape_queue_sup, to_name(key)})

  def to_name(key) when is_bitstring(key),
    do: "scape.system.#{key}"
end
