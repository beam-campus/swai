defmodule Nature.Service do
  use GenServer, restart: :transient

  @moduledoc """
  Logatron.Fields.Server contains the GenServer for the Server.
  """

  alias Nature.Facts, as: NatureFacts
  alias Nature.Init, as: NatureInit
  alias Phoenix.PubSub

  @nature_cache_updated_v1 NatureFacts.nature_cache_updated_v1
  @initializing_influence_v1 NatureFacts.initializing_influence_v1
  

  ################### PUBLIC API ###################
  def get_all_for_mng_farm_id(mng_farm_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_all_for_mng_farm, mng_farm_id}
      )

  def get_all(),
    do:
      GenServer.call(
        __MODULE__,
        {:get_all}
      )

  def get_stream(),
    do:
      GenServer.call(
        __MODULE__,
        {:get_stream}
      )

  def get(field_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get, field_id}
      )

  def save(field_init),
    do:
      GenServer.cast(
        __MODULE__,
        {:save, field_init}
      )

  ################### INTERNALS ###################
  defp notify_cache_updated(cause),
    do:
      PubSub.broadcast!(
        Logatron.PubSub,
        @nature_cache_updated_v1,
        cause
      )

  #################### CALLBACKS ####################

  @impl GenServer
  def handle_cast({:save, %NatureInit{} = nature_init}, state) do
    key = %{
      id: nature_init.id,
      edge_id: nature_init.edge_id,
      scape_id: nature_init.scape_id,
      region_id: nature_init.region_id,
      mng_farm_id: nature_init.mng_farm_id,
      field_id: nature_init.field_id
    }
    :nature_cache
    |> Cachex.put!(key, nature_init)

    notify_cache_updated({:save, nature_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, nature_id}, _from, state) do
    {
      :reply,
      :nature_cache
      |> Cachex.get!(%{id: nature_id}),
      state
    }
  end

  @impl GenServer
  def handle_call({:get_all}, _from, state) do
    {
      :reply,
      :nature_cache
      |> Cachex.stream!()
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, nature_init} -> nature_init end)
      |> Enum.reverse(),
      state
    }
  end

  @impl GenServer
  def handle_call({:get_stream}, _from, state) do
    {
      :reply,
      :nature_cache
      |> Cachex.stream!(),
      state
    }
  end

  @impl GenServer
  def handle_call({:get_all_for_mng_farm, mng_farm_id}, _from, state) do
    {
      :reply,
      :fields_cache
      |> Cachex.stream!()
      |> Enum.filter(fn {:entry, key, _nil, _internal_id, _nature_init} -> key.mng_farm_id == mng_farm_id end)
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, nature_init} -> nature_init end),
      state
    }
  end

  ############################ handle_info ############################

  @impl GenServer
  def handle_info({@initializing_influence_v1, %NatureInit{} = field_init}, state) do
    key = %{
      id: field_init.id,
      mng_farm_id: field_init.mng_farm_id
    }
    :fields_cache
    |> Cachex.put!(key, field_init)

    notify_cache_updated({@initializing_influence_v1, field_init})
    {:noreply, state}
  end

  # @impl GenServer
  # def handle_info({@field_initialized_v1, %FieldInit{} = field_init}, state) do
  #   key = %{
  #     id: field_init.id,
  #     mng_farm_id: field_init.mng_farm_id
  #   }

  #   :fields_cache
  #   |> Cachex.put!(key, field_init)

  #   notify_cache_updated({@field_initialized_v1, field_init})
  #   {:noreply, state}
  # end

  @impl true
  def init(opts) do

    PubSub.subscribe(Logatron.PubSub, @initializing_influence_v1)

    {:ok, opts}
  end

  ############ PLUMBING ############

  defp to_name(effect_id),
    do: "nature.service.#{effect_id}"

  def via(nature_id),
    do: Edge.Registry.via_tuple({:nature_srv, to_name(nature_id)})

  def child_spec(opts),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }

  def start_link(opts),
    do:
      GenServer.start_link(
        __MODULE__,
        opts,
        name: __MODULE__
      )
end
