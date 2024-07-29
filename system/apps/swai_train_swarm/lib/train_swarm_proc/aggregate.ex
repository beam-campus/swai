defmodule TrainSwarmProc.Aggregate do
  @moduledoc """
  This module defines the aggregate for the Train Swarm Process.
  """
  use Ecto.Schema


  alias TrainSwarmProc.Aggregate, as: Aggregate
  alias TrainSwarmProc.Schema.Root, as: Root
  alias Schema.SwarmTraining, as: SwarmTraining
  alias Schema.SwarmTraining.Status, as: Status
  alias TrainSwarmProc.Initialize.Evt.V1, as: Initialized
  alias TrainSwarmProc.Initialize.Payload.V1, as: InitPayload
  alias TrainSwarmProc.Configure.Evt.V1, as: Configured
  alias TrainSwarmProc.Configure.Payload.V1, as: ConfigPayload

  require Jason.Encoder

  @proc_unknown Status.unknown()
  @proc_initialized Status.initialized()
  @proc_configured Status.configured()

  @all_fields [
    :agg_id,
    :status,
    :state
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:agg_id, :binary_id)
    field(:status, :integer, default: @proc_unknown)
    embeds_one(:state, Root)
  end

  def apply(
        %Aggregate{state: nil} = _agg,
        %Initialized{payload: %InitPayload{} = payload} = evt
      ),
      do: %Aggregate{
        agg_id: evt.agg_id,
        status: @proc_initialized,
        state: %Root{
          swarm_training: %SwarmTraining{
            status: @proc_initialized,
            swarm_id: payload.swarm_id,
            user_id: payload.user_id,
            biotope_id: payload.biotope_id,
            biotope_name: payload.biotope_name
          }
        }
      }

  def apply(
        %Aggregate{state: %Root{} = state} = agg,
        %Configured{payload: %ConfigPayload{} = payload} = evt
      ) do
    %Aggregate{
      agg
      | status: @proc_configured,
        state: %Root{
          state
          | swarm_training: %SwarmTraining{
              state.swarm_training
              | status: @proc_configured,
                swarm_size: payload.swarm_size,
                nbr_of_generations: payload.nbr_of_generations,
                drone_depth: payload.drone_depth,
                generation_epoch_in_minutes: payload.generation_epoch_in_minutes,
                select_best_count: payload.select_best_count,
                cost_in_tokens: payload.cost_in_tokens
            }
          }
    }
  end
end
