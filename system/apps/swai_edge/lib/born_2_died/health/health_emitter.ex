defmodule Born2Died.HealthEmitter do
  # use GenServer, restart: :transient

  @moduledoc """
  Born2Died.HealthEmitter is a GenServer that manages a channel to client
  """

  alias Born2Died.State, as: LifeState
  alias Edge.Client, as: Client
  alias Born2Died.Facts, as: LifeFacts
  alias Phoenix.PubSub, as: Exchange

  require Logger

  @initializing_life_v1 LifeFacts.initializing_life_v1()
  @life_initialized_v1 LifeFacts.life_initialized_v1()
  @life_state_changed_v1 LifeFacts.life_state_changed_v1()
  @life_detached_v1 LifeFacts.life_detached_v1()
  @life_died_v1 LifeFacts.life_died_v1()

  ############ API ############

  def emit_initializing_life(life_init),
    do:
      Client.publish(
        life_init.edge_id,
        @initializing_life_v1,
        %{life_init: life_init}
      )

  def emit_life_detached(life_init),
    do:
      Client.publish(
        life_init.edge_id,
        @life_detached_v1,
        %{life_init: life_init}
      )

  def emit_life_initialized(%LifeState{} = life) do
    Exchange.broadcast!(
      Edge.PubSub,
      @life_initialized_v1,
      {@life_initialized_v1, life}
    )

    Client.publish(
      life.edge_id,
      @life_initialized_v1,
      %{life_init: life}
    )
  end

  def emit_life_state_changed(life_init),
    do:
      Client.publish(
        life_init.edge_id,
        @life_state_changed_v1,
        %{life_init: life_init}
      )

  def emit_life_died(life_init),
    do:
      Client.publish(
        life_init.edge_id,
        @life_died_v1,
        %{life_init: life_init}
      )

  # def emit_initializing_life(%LifeState{} = life_state),
  #   do:
  #     GenServer.cast(
  #       via(life_state.id),
  #       {:initializing_life, life_state}
  #     )

  # def emit_life_initialized(%LifeState{} = life_init),
  #   do:
  #     GenServer.cast(
  #       via(life_init.id),
  #       {:life_initialized, life_init}
  #     )

  # def emit_life_died(%LifeState{} = life_init),
  #   do:
  #     GenServer.cast(
  #       via(life_init.id),
  #       {:life_died, life_init}
  #     )

  # def life_state_changed(%LifeState{} = life_init),
  #   do:
  #     GenServer.cast(
  #       via(life_init.life.id),
  #       {:life_state_changed, life_init}
  #     )

  # ############ CALLBACKS ############

  # @impl GenServer
  # def handle_cast({:life_died, %LifeState{} = life_init}, state) do
  #   Client.publish(
  #     life_init.edge_id,
  #     @life_died_v1,
  #     %{life_init: life_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_cast({:initializing_life, %LifeState{} = life_init}, state) do
  #   Client.publish(
  #     life_init.edge_id,
  #     @initializing_life_v1,
  #     %{life_init: life_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_cast({:life_initialized, %LifeState{} = life_init}, state) do
  #   Client.publish(
  #     life_init.edge_id,
  #     @life_initialized_v1,
  #     %{life_init: life_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_cast({:life_state_changed, %LifeState{} = life_init}, state) do
  #   Client.publish(
  #     life_init.edge_id,
  #     @life_state_changed_v1,
  #     %{life_init: life_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_cast({:life_detached, %LifeState{} = life_init}, state) do
  #   Client.publish(
  #     life_init.edge_id,
  #     @life_detached_v1,
  #     %{life_init: life_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_info({:after_join, _}, state) do
  #   Logger.debug("health.emitter received: :after_join")
  #   {:noreply, state}
  # end

  # @impl GenServer
  # def init(%LifeState{} = life_init) do
  #   Logger.info("health.emitter: #{Colors.born2died_theme(self())}")
  #   {:ok, life_init}
  # end

  # ########### PLUMBING ###########
  # defp to_name(life_id),
  #   do: "health.emitter.#{life_id}"

  # def via(life_id),
  #   do: Edge.Registry.via_tuple(to_name(life_id))

  # def start_link(%LifeState{} = life_init),
  #   do:
  #     GenServer.start_link(
  #       __MODULE__,
  #       life_init,
  #       name: via(life_init.id)
  #     )

  # def child_spec(%LifeState{} = life_init) do
  #   %{
  #     id: to_name(life_init.id),
  #     start: {__MODULE__, :start_link, [life_init]},
  #     type: :worker,
  #     restart: :transient
  #   }
  # end
end
