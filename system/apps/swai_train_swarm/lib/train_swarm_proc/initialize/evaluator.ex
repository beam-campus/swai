defmodule TrainSwarmProc.Initialize.Evaluator do
  @moduledoc """
  Commanded handler for initializing the swarm training process.
  """
  @behaviour Commanded.Commands.Handler

  import Flags


  alias Commanded.Aggregate.Multi,    as: Multi
  alias TrainSwarmProc.Aggregate,    as: Aggregate
  alias TrainSwarmProc.Initialize.Cmd.V1,    as: Initialize
  alias TrainSwarmProc.Initialize.Evt.V1,    as: Initialized
  alias TrainSwarmProc.Initialize.Payload.V1,    as: InitPayload
  alias TrainSwarmProc.Configure.Evt.V1,    as: Configured
  alias TrainSwarmProc.Configure.Payload.V1,    as: ConfigPayload
  alias Schema.SwarmTraining,    as: SwarmTraining
  alias TrainSwarmProc.Schema.Root,    as: Root
  alias Schema.SwarmTraining.Status,    as: Status

  @proc_unknown Status.unknown()
  @proc_initialized Status.initialized()

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
        %Aggregate{} = aggregate,
        %Initialize{} = cmd
      ) do
    cond do
      aggregate.status
      |> has?(@proc_unknown) ->
        raise_initialize_events(aggregate, cmd)

      aggregate.status
      |> has?(@proc_initialized) ->
        {:error, :already_initialized}

      true ->
        {:error, :already_initialized}
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

  defp raise_initialized(
         _aggregate,
         %Initialize{payload: %SwarmTraining{} = cmd_payload} = cmd
       ) do
    evt = %Initialized{
      agg_id: cmd.agg_id,
      payload: %InitPayload{
        swarm_id: cmd_payload.swarm_id,
        user_id: cmd_payload.user_id,
        biotope_id: cmd_payload.biotope_id,
        biotope_name: cmd_payload.biotope_name,
        scape_id: cmd_payload.scape_id,
        swarm_name: cmd_payload.swarm_name
      }
    }

    {:ok, evt}
  end

  defp raise_configured(
         _aggregate,
         %Initialize{payload: %SwarmTraining{} = cmd_payload} = cmd
       ) do
    evt = %Configured{
      agg_id: cmd.agg_id,

      payload: %ConfigPayload{
        swarm_size: cmd_payload.swarm_size,
        nbr_of_generations: cmd_payload.nbr_of_generations,
        drone_depth: cmd_payload.drone_depth,
        generation_epoch_in_minutes: cmd_payload.generation_epoch_in_minutes,
        select_best_count: cmd_payload.select_best_count,
        cost_in_tokens: cmd_payload.cost_in_tokens,
      }
    }

    {:ok, evt}
  end
end
