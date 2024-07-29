defmodule SwarmTrainings.Service do
  @moduledoc """
  The service wrapper module for the swarm trainings cache.
  """
  use GenServer

  alias Colors, as: Colors
  alias Phoenix.PubSub, as: PubSub
  alias Schema.SwarmTraining, as: SwarmTraining
  alias Schema.SwarmTraining.Status, as: Status
  alias TrainSwarmProc.Facts, as: Facts
  alias TrainSwarmProc.Initialize.Payload.V1, as: InitPayload
  alias TrainSwarmProc.Configure.Payload.V1, as: ConfigPayload
  alias TrainSwarmProc.Initialize.Evt.V1, as: Initialized
  alias TrainSwarmProc.Configure.Evt.V1, as: Configured
  alias Cachex, as: Cachex

  alias Swai.Workspace, as: Workspace

  require Logger

  @initialized Status.initialized()
  @configured Status.configured()

  @swarm_trainings_updated_v1 Facts.cache_updated_v1()
  @swarm_training_initialized_v1 Facts.initialized()
  @swarm_training_configured_v1 Facts.configured()

  @user_id "user_id"
  @biotope_name "biotope_name"
  @swarm_size "swarm_size"

  ################## API ##################
  def count(),
    do:
      GenServer.call(
        __MODULE__,
        :count
      )

  def get_all(),
    do:
      GenServer.call(
        __MODULE__,
        :get_all
      )

  def get_all_for_user(user_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_all_for_user, user_id}
      )

  ############ INTERNALS ###############
  defp notify_swarm_trainings_updated(cause) do
    res = Swai.PubSub
    |> PubSub.broadcast!(
      @swarm_trainings_updated_v1,
      cause
    )
    Logger.alert("Notified SwarmTrainings Cache Updated #{inspect(cause)} => #{inspect(res)}")
  end

  defp init_cache_from_store() do
    Logger.info("Initializing SwarmTrainings Cache from Store")

    :swarm_trainings_cache
    |> Cachex.clear!()

    Workspace.list_swarm_trainings()
    |> Enum.each(fn st ->
      :swarm_trainings_cache
      |> Cachex.put!(st.id, st)
    end)
  end

  ################# COUNT ##############
  @impl true
  def handle_call(:count, _from, state) do
    {
      :reply,
      :swarm_trainings_cache
      |> Cachex.count!(),
      state
    }
  end

  ################# GET_ALL ##############
  @impl true
  def handle_call(:get_all, _from, state) do
    {
      :reply,
      :swarm_trainings_cache
      |> Cachex.stream!()
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, st} -> st end),
      state
    }
  end

  ################# GET_ALL_FOR_USER ##############
  @impl true
  def handle_call({:get_all_for_user, user_id}, _from, state) do
    {
      :reply,
      :swarm_trainings_cache
      |> Cachex.stream!()
      |> Enum.filter(fn {:entry, _key, _nil, _internal_id, st} ->
        st.user_id == user_id
      end)
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, st} -> st end),
      state
    }
  end

  ################# INIT ###################
  @impl true
  def init(args) do
    Logger.info(
      "Starting SwarmTrainings.Service with args #{inspect(args)} => #{Colors.region_theme(self())}"
    )

    init_cache_from_store()

    Swai.PubSub
    |> PubSub.subscribe(@swarm_training_initialized_v1)

    Swai.PubSub
    |> PubSub.subscribe(@swarm_training_configured_v1)

    {:ok, %{}}
  end

  ################# HANDLE_INITIALIZED ###########
  @impl true
  def handle_info(
        {
          @swarm_training_initialized_v1,
          %Initialized{
            agg_id: agg_id,
            version: _version,
            payload: payload
          } = evt,
          metadata
        },
        state
      ) do
    Logger.alert("ADDING SwarmTraining due to #{inspect(evt)} with metadata #{inspect(metadata)}")
    seed = %SwarmTraining{id: agg_id}

    case SwarmTraining.from_map(seed, payload) do
      {:ok, %SwarmTraining{} = st} ->
        if :swarm_trainings_cache
           |> Cachex.put!(agg_id, st) do
          notify_swarm_trainings_updated({
            @swarm_training_initialized_v1,
            st,
            metadata
          })
        end

      {:error, _reason} ->
        Logger.error("Failed to create SwarmTraining from #{inspect(payload)}")
    end

    {:noreply, state}
  end

  ################# HANDLE_CONFIGURED ###########

  @impl true
  def handle_info(
        {
          @swarm_training_configured_v1,
          %Configured{
            agg_id: agg_id,
            version: _version,
            payload: payload
          } = evt,
          metadata
        },
        state
      ) do
    Logger.alert("CONFIGURING SwarmTraining due to #{inspect(evt)}")

    st =
      :swarm_trainings_cache
      |> Cachex.get!(agg_id)

    case SwarmTraining.from_map(st, payload) do
      {:ok, st} ->
        st = %SwarmTraining{
          st
          | status: @configured,
            swarm_size: payload.swarm_size,
            nbr_of_generations: payload.nbr_of_generations,
            drone_depth: payload.drone_depth,
            generation_epoch_in_minutes: payload.generation_epoch_in_minutes,
            select_best_count: payload.select_best_count,
            cost_in_tokens: payload.cost_in_tokens
        }

        if :swarm_trainings_cache
           |> Cachex.update!(agg_id, st) do
          notify_swarm_trainings_updated({
            @swarm_training_configured_v1,
            st,
            metadata
          })
        end

      {:error, _reason} ->
        Logger.error("Failed to update SwarmTraining from #{inspect(payload)}")
    end

    {:noreply, state}
  end

  ################### PLUMBING ###################
  def child_spec(init_arg),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      type: :worker
    }

  def start_link(args),
    do:
      GenServer.start_link(
        __MODULE__,
        [args],
        name: __MODULE__
      )
end
