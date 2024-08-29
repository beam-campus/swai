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

  alias TrainSwarmProc.ConfigureLicense.EvtV1, as: LicenseConfigured

  alias TrainSwarmProc.PayLicense.CmdV1, as: PayLicense
  alias Schema.SwarmLicense, as: Payment
  alias TrainSwarmProc.PayLicense.EvtV1, as: Paid
  alias TrainSwarmProc.PayLicense.BudgetReachedV1, as: BudgetReached
  alias TrainSwarmProc.ActivateLicense.CmdV1, as: Activate
  alias Schema.SwarmLicense, as: Activation
  alias TrainSwarmProc.ActivateLicense.EvtV1, as: LicenseActivated
  alias TrainSwarmProc.QueueLicense.CmdV1, as: QueueLicense
  alias Scape.Init, as: ScapeInit
  alias Schema.Vector, as: Vector
  alias TrainSwarmProc.BlockLicense.CmdV1, as: BlockLicense
  alias Schema.SwarmLicense, as: BlockInfo
  alias TrainSwarmProc.PauseScape.CmdV1, as: PauseScape
  alias TrainSwarmProc.DetachScape.EvtV1, as: ScapeDetached




  require Logger

  def interested?(%LicenseConfigured{} = event), do: {:start, event}
  def interested?(%Paid{} = event), do: {:start, event}
  def interested?(%BudgetReached{} = event), do: {:start, event}
  def interested?(%LicenseActivated{} = event), do: {:start, event}
  def interested?(%ScapeDetached{} = event), do: {:start, event}

  def interested?(_event), do: false

  #################### HANDLE INCOMING EVENTS AND THROW THE COMMANDS ####################

  #################### CONFIGURED TRIGGERS PAYMENT ####################
  def handle(
        %Policies{} = _policies,
        %LicenseConfigured{agg_id: agg_id, payload: configuration} = _event
      ) do
    case Payment.from_map(%Payment{}, configuration) do
      {:ok, payment} ->
        %PayLicense{agg_id: agg_id, payload: payment}

      {:error, changeset} ->
        Logger.error("invalid configuration for payment \n #{inspect(changeset)}")
        {:error, "invalid configuration"}
    end
  end

  #################### PAYMENT TRIGGERS ACTIVATION ####################
  def handle(
        %Policies{} = _policies,
        %Paid{agg_id: agg_id, payload: payment} = _event
      ) do
    case Activation.from_map(%Activation{}, payment) do
      {:ok, activation} ->
        %Activate{agg_id: agg_id, payload: activation}

      {:error, changeset} ->
        Logger.error("invalid payment for activation\n #{inspect(changeset)}")
        {:error, "invalid payment, cannot activate"}
    end
  end

  #################### LICENSE ACTIVATION TRIGGERS SCAPE QUEUING ####################
  def handle(
        %Policies{} = _policies,
        %LicenseActivated{agg_id: agg_id, payload: activation} = _event
      ) do
    seed =
      %ScapeInit{
        dimensions: Vector.default_map_dimensions()
      }

    case ScapeInit.from_map(seed, activation) do
      {:ok, scape_init} ->
        %QueueLicense{agg_id: agg_id, payload: scape_init}

      {:error, changeset} ->
        Logger.error("invalid activation for scape queuing\n #{inspect(changeset)}")
        {:error, "invalid activation, cannot queue scape"}
    end
  end

  #################### BUDGET REACHED TRIGGERS BLOCKING ####################
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
  end


  ######################## SCAPE DETACHED TRIGGERS PAUSE SCAPE ########################
  def handle(
        %Policies{} = _policies,
        %ScapeDetached{agg_id: agg_id, payload: scape_init} = _event
      ) do
    %PauseScape{
      agg_id: agg_id,
      version: 1,
      payload: scape_init
    }
  end

  # Stop Policies after three failures
  def error({:error, _failure}, _failed_message, %{context: %{failures: failures}})
      when failures >= 4 do
    {:stop, :too_many_failures}
  end

  # Retry command, record failure count in context map
  def error({:error, _failure}, _failed_message, %{context: context}) do
    context = Map.update(context, :failures, 1, fn failures -> failures + 1 end)
    {:retry, context}
  end
end
