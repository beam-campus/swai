defmodule TrainSwarmProc.Policies do
  @moduledoc """
  Commanded process manager for starting the swarm training process.
  """
  use Commanded.ProcessManagers.ProcessManager,
    application: TrainSwarmProc.CommandedApp,
    name: "TrainSwarmProc.Policies"

  @all_fields [
    :agg_id,
    :state
  ]

  require Jason.Encoder

  @derive {Jason.Encoder, only: @all_fields}
  defstruct [
    :agg_id,
    :state
  ]

  alias TrainSwarmProc.Policies, as: Policies

  alias TrainSwarmProc.Configure.EvtV1, as: Configured

  alias TrainSwarmProc.PayLicense.CmdV1, as: PayLicense
  alias TrainSwarmProc.PayLicense.PayloadV1, as: Payment
  alias TrainSwarmProc.PayLicense.EvtV1, as: Paid
  alias TrainSwarmProc.PayLicense.BudgetReachedV1, as: BudgetReached

  alias TrainSwarmProc.Activate.CmdV1, as: Activate
  alias TrainSwarmProc.Activate.PayloadV1, as: Activation
  alias TrainSwarmProc.Activate.EvtV1, as: Activated

  alias TrainSwarmProc.QueueScape.CmdV1, as: QueueScape
  alias Scape.Init, as: ScapeInit
  alias Schema.Vector, as: Vector

  alias TrainSwarmProc.BlockLicense.CmdV1, as: BlockLicense
  alias TrainSwarmProc.BlockLicense.PayloadV1, as: BlockInfo

  require Logger

  def interested?(%Configured{} = event), do: {:start, event}
  def interested?(%Paid{} = event), do: {:start, event}
  def interested?(%BudgetReached{} = event), do: {:start, event}
  def interested?(%Activated{} = event), do: {:start, event}
  def interested?(_event), do: false

  #################### HANDLE INCOMING EVENTS AND THROW THE COMMANDS ####################
  def handle(
        %Policies{} = _policies,
        %Configured{agg_id: agg_id, payload: configuration} = _event
      ) do
    {:ok, payload} =
      Payment.from_map(%Payment{}, configuration)

    %PayLicense{agg_id: agg_id, payload: payload}
  end

  def handle(
        %Policies{} = _policies,
        %Paid{agg_id: agg_id, payload: payment} = _event
      ) do
    {:ok, activation} =
      Activation.from_map(%Activation{}, payment)

    %Activate{agg_id: agg_id, payload: activation}
  end

  def handle(
        %Policies{} = _policies,
        %Activated{agg_id: agg_id, payload: activation} = _event
      ) do
    seed =
      %ScapeInit{
        dimensions: Vector.default_map_dimensions()
      }

    {:ok, scape_init} = ScapeInit.from_map(seed, activation)

    %QueueScape{agg_id: agg_id, payload: scape_init}
  end

  def handle(
        %Policies{} = _policies,
        %BudgetReached{agg_id: agg_id, payload: budget_info} = _event
      ) do
    %BlockLicense{
      agg_id: agg_id,
      version: 1,
      payload: %BlockInfo{
        reason: "Budget reached",
        additional_info:
          "This is temporarily blocked because the budget has been reached.
        Your current budget is #{budget_info.current_budget}👾 and the required budget is #{budget_info.required_budget}👾.",
        instructions: "Please increase your budget to continue."
      }
    }

    # {:ok, cmd} = BlockLicense.from_map(seed, event)
    # cmd
  end

  # Stop process manager after three failures
  def error({:error, _failure}, _failed_message, %{context: %{failures: failures}})   when failures >= 4 do
    {:stop, :too_many_failures}
  end

  # Retry command, record failure count in context map
  def error({:error, _failure}, _failed_message, %{context: context}) do
    context = Map.update(context, :failures, 1, fn failures -> failures + 1 end)
    {:retry, context}
  end


end
