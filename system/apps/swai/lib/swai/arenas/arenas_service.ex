defmodule Arenas.Service do
  @moduledoc false
  use GenServer

  require Logger

  def start(cache_file) do
    case start_link(cache_file) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:errer, reason} ->
        Logger.error("Failed to start #{__MODULE__}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  ## plumbing
  @impl GenServer
  def init(cache_file) do
    Process.flag(:trap_exit, true)

    {:ok, cache_file}
  end

  # def to_name(key),
  #   do: "arenas.service.#{key}"
  #
  # def via(scape_id),
  #   do: SwaiRegistry.via_tuple({:arenas, to_name(scape_id)})
  #
  defp start_link(cache_file),
    do:
      GenServer.start_link(
        __MODULE__,
        cache_file,
        name: __MODULE__
      )

  def child_spec(cache_file),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start, [cache_file]},
      type: :supervisor,
      restart: :transient
    }
end
