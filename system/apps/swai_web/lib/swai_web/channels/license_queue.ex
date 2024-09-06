defmodule SwaiWeb.LicenseQueue do
  @moduledoc """
  The LicenseQueue is used to broadcast messages to all clients
  """
  use GenServer

  require Logger

  # alias SwaiWeb.EdgeChannel
  # alias Edges.Service, as: Edges
  # alias Licenses.Service, as: Licenses
  # alias Hives.Service, as: Hives
  #
  require Logger
  require Colors

  ################# INIT ##########################
  @impl true
  def init(_init_args \\ []) do
    Logger.debug("LicenseQueue is up: #{Colors.server_theme(self())}")
    Process.send_after(self(), :pop_queue, 1_000)
    {:ok, []}
  end

  # defp try_present_license(license) do
  #   Logger.warning("
  #     ***** WARNING *****
  #     Automatic License presentation is disabled!
  #     The mechanism has changed.
  #     Implement edge/backend logic first!
  #     ***** WARNING *****
  #
  #     License:
  #
  #     #{inspect(license)}
  #
  #     ***** WARNING *****")
  #
  #   case Hives.get_candidates_for_license(license) do
  #     [] ->
  #       Logger.warning("No candidates for license: #{inspect(license)}")
  #
  #     candidates ->
  #       Logger.debug("Candidates for license: #{inspect(candidates)}")
  #
  #       candidates
  #       |> Enum.random()
  #       |> EdgeChannel.queue_license(license)
  #   end
  #
  #   #    case Edges.get_candidates_for_biotope(license.biotope_id) do
  #   #      [] ->
  #   #        "no candidates"
  #   #
  #   #      edges ->
  #   #          edges
  #   #          |> Enum.random()
  #   #          |> EdgeChannel.queue_license(license)
  #   #    end
  # end

  ################# POP_QUEUE #####################
  # @impl true
  # def handle_info(:pop_queue, state) do
  #   state =
  #     case Licenses.get_all_queued_or_paused() do
  #       [] ->
  #         state
  #
  #       queued ->
  #         queued
  #         |> Enum.map(&try_present_license/1)
  #     end
  #
  #   #    Process.send_after(self(), :pop_queue, 10_000)
  #   {:noreply, state}
  # end
  #

  @impl true
  def handle_info(_, state) do
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
