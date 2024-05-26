defmodule MngFarm.Emitter do
  # use GenServer, restart: :transient

  @moduledoc """
  The Emitter module is used to emit facts from the MngFarm subsystem upstream.
  """

  require Logger

  alias Edge.Client, as: EdgeClient
  alias Field.Init, as: FieldInit
  alias Field.Facts, as: FieldFacts

  @initializing_field_v1 FieldFacts.initializing_field_v1
  @field_initialized_v1 FieldFacts.field_initialized_v1


  def emit_initializing_field(%FieldInit{} = field_init),
    do:
      EdgeClient.publish(
        field_init.edge_id,
        @initializing_field_v1,
        %{field_init: field_init}
      )

  def emit_field_initialized(%FieldInit{} = field_init),
    do:
      EdgeClient.publish(
        field_init.edge_id,
        @field_initialized_v1,
        %{field_init: field_init}
      )



  ####################  API  ####################
  # def emit_initializing_field(%FieldInit{} = field_init),
  #   do:
  #     GenServer.cast(
  #       via(field_init.mng_farm_id),
  #       {:initializing_field_v1, field_init}
  #     )

  # def emit_field_initialized(%FieldInit{} = field_init),
  #   do:
  #     GenServer.cast(
  #       via(field_init.farm_id),
  #       {:field_initialized_v1, field_init}
  #     )



  ################### CALLBACKS ###################

  # @impl GenServer
  # def handle_cast({:initializing_field_v1, %FieldInit{} = field_init}, state) do
  #   Logger.debug("emitting: initializing_field_v1")
  #   EdgeClient.publish(
  #     field_init.edge_id,
  #     @initializing_field_v1,
  #     %{field_init: field_init}
  #   )
  #   {:noreply, state}
  # end


  # @impl GenServer
  # def handle_cast({:field_initialized_v1, %FieldInit{} = field_init}, state) do
  #   EdgeClient.publish(
  #     field_init.edge_id,
  #     @field_initialized_v1,
  #     %{field_init: field_init}
  #   )
  #   {:noreply, state}
  # end

  # @impl GenServer
  # def init(%FarmInit{} = farm_init),
  #   do: {:ok, farm_init}

  # ########### PLUMBING ###########
  # def via(farm_id),
  #   do: Edge.Registry.via_tuple({:farm_emitter, to_name(farm_id)})

  # def to_name(farm_id),
  #   do: "farm.emitter.#{farm_id}"

  # def start_link(%FarmInit{} = farm_init) do
  #   GenServer.start_link(
  #     __MODULE__,
  #     farm_init,
  #     name: via(farm_init.id)
  #   )
  # end
end
