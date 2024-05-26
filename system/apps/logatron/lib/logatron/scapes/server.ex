defmodule Scapes.Service do
  use GenServer

  @moduledoc """
  Scapes.Service contains the GenServer for the Server.
  """

  require Cachex
  require Logger
  alias Phoenix.PubSub
  alias Scape.Facts, as: ScapeFacts

  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scapes_cache_updated_v1 ScapeFacts.scapes_cache_updated_v1()

  #################### PUBLIC API ##################
  def get_all(),
    do:
      GenServer.call(
        __MODULE__,
        :get_all
      )

  def get_stream(),
    do:
      GenServer.call(
        __MODULE__,
        :get_stream
      )

  def get_summary(),
    do:
      GenServer.call(
        __MODULE__,
        :get_summary
      )

  #################### CALLBACKS  ##################

  @impl true
  def handle_cast({:update_scape_status, status}, state),
    do: {:noreply, %{state | status: status}}

  ########### handle_call ###########
  @impl true
  def handle_call(:get_all, _from, state) do
    result =
      :scapes_cache
      |> Cachex.stream!()
      |> Enum.map(fn {:entry, _id, _internal_key, _nil, scape} -> scape end)

    {:reply, result, state}
  end

  @impl true
  def handle_call(:get_stream, _from, state) do
    result =
      :scapes_cache
      |> Cachex.stream!()

    {:reply, result, state}
  end

  @impl true
  def handle_call(:get_summary, _from, state) do
    result =
      :scapes_cache
      |> Cachex.stream!()
      |> Stream.map(fn {:entry, _, _, _, scape} -> scape end)
      |> Enum.reduce(%{}, fn scape, acc -> Map.update(acc, scape.id, 1, &(&1 + 1)) end)
      |> Map.to_list()
      |> Enum.sort()

    {:reply, result, state}
  end

  ########### handle_info ###########
  @impl true
  def handle_info({@initializing_scape_v1, scape_init}, state) do
    Logger.info("Initializing scape: #{@initializing_scape_v1} #{inspect(scape_init)}")

    key = %{
      edge_id: scape_init.edge_id,
      id: scape_init.id
    }

    :scapes_cache
    |> Cachex.put(key, scape_init)

    notify_cache_updated(@initializing_scape_v1, scape_init)

    {:noreply, state}
  end

  @impl true
  def init(init_args) do
    Logger.info(
      "Starting Scapes.Service, subscribing to Logatron.PubSub topics ... #{@initializing_scape_v1}"
    )
    PubSub.subscribe(Logatron.PubSub, @initializing_scape_v1)

    {:ok, init_args}
  end

  @impl true
  def terminate(_reason, state) do
    {:ok, state}
  end

  ###################  PRIVATE  ###################
  defp notify_cache_updated(cause, scape_init),
    do:
      PubSub.broadcast!(
        Logatron.PubSub,
        @scapes_cache_updated_v1,
        {cause, scape_init}
      )

  ###################  PLUMBING  ###################

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def child_spec(_scape_init) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent
    }
  end
end
