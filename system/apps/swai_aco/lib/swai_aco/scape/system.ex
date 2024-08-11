defmodule Scape.System do
  @moduledoc """
  Scape.System is the top-level supervisor for the Swai.MngScape subsystem.
  """
  use GenServer

  require Logger

  alias Edge.Emitter, as: EdgeEmitter
  alias Scape.Init, as: ScapeInit
  alias Swai.Registry, as: EdgeRegistry

  @doc """
  Returns the list of children supervised by this module
  """
  def which_children(scape_id) do
    try do
      Supervisor.which_children(via_sup(scape_id))
      |> Enum.reverse()
    rescue
      _ -> []
    end
  end

  ####### CALLBACKS ############
  # @impl GenServer
  # def handle_info({:EXIT, from_pid, reason}, state) do
  #   Logger.error(
  #     "#{Colors.red_on_black()}EXIT received from #{inspect(from_pid)} reason: #{inspect(reason)}#{Colors.reset()}"
  #   )

  #   Channel.scape_detached(state)

  #   {:noreply, state}
  # end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.error("#{Colors.red_on_black()}received: [#{msg}]")
    {:noreply, state}
  end


  @impl GenServer
  def terminate(reason, scape_init) do
    Logger.error(
      "#{Colors.red_on_black()}Terminating Scape.System with reason: #{inspect(reason)}#{Colors.reset()}"
    )

    {:ok, scape_init}
  end

  @impl GenServer
  def init(%ScapeInit{} = scape_init) do
    # Process.flag(:trap_exit, true)
    Logger.debug("scape.system: #{Colors.scape_theme(self())}")

    EdgeEmitter.emit_initializing_scape(scape_init)

    children = [

      # {Scape.Emitter, scape_init},
      {Scape.Builder, scape_init}
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: via_sup(scape_init.id)
    )

    EdgeEmitter.emit_scape_initialized(scape_init)

    {:ok, scape_init}
  end



  ################# PLUMBIMG #####################
  def via(key),
    do: EdgeRegistry.via_tuple({:scape_system, to_name(key)})

  def via_sup(key),
    do: EdgeRegistry.via_tuple({:scape_sup, to_name(key)})

  def to_name(key) when is_bitstring(key),
    do: "scape.system.#{key}"

  def child_spec(%{id: scape_id} = scape_init),
    do: %{
      id: via(scape_id),
      start: {__MODULE__, :start_link, [scape_init]},
      type: :supervisor,
      restart: :transient,
      shutdown: 500
    }

  def start_link(%ScapeInit{} = scape_init),
    do:
      GenServer.start_link(
        __MODULE__,
        scape_init,
        name: via(scape_init.id)
      )
end
