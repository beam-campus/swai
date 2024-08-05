defmodule TrainSwarmProc.Initialize.Evaluator do
  @moduledoc """
  Commanded handler for initializing the swarm training process.
  """
  @behaviour Commanded.Commands.Handler

  import Flags

  alias Commanded.Aggregate.Multi, as: Multi
  alias TrainSwarmProc.Aggregate, as: Aggregate
  alias TrainSwarmProc.Initialize.CmdV1, as: Initialize
  alias TrainSwarmProc.Initialize.EvtV1, as: Initialized
  alias TrainSwarmProc.Configure.EvtV1, as: Configured
  alias Schema.SwarmLicense.Status, as: Status

  @proc_unknown Status.unknown()
  @proc_initialized Status.license_initialized()

  require Logger

  #################### API ###################
  @impl true
  def handle(
        %Aggregate{agg_id: nil, state: nil} = aggregate,
        %Initialize{} = cmd
      ) do
    raise_initialize_events(aggregate, cmd)
  end

  @impl true
  def handle(
        %Aggregate{status: status} = aggregate,
        %Initialize{} = cmd
      ) do
    cond do
      status
      |> has?(@proc_unknown) ->
        raise_initialize_events(aggregate, cmd)

      status
      |> has?(@proc_initialized) ->
        {:error, :already_initialized}

      true ->
        {:error, :unknown_error}
    end
  end

  #################### RAISE FUNCTIONS ####################

  defp raise_initialize_events(
         %Aggregate{} = aggregate,
         %Initialize{} = cmd
       ) do
    aggregate
    |> Multi.new()
    |> Multi.execute(&raise_initialized(&1, cmd))
    |> Multi.execute(&raise_configured(&1, cmd))
  end

  defp raise_initialized(_, cmd) do
    case Initialized.from_map(%Initialized{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp raise_configured(_, cmd) do
    case Configured.from_map(%Configured{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
