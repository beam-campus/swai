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

  alias TrainSwarmProc.Activate.CmdV1, as: Activate
  alias TrainSwarmProc.Activate.PayloadV1, as: Activation
  alias TrainSwarmProc.Activate.EvtV1, as: Activated

  alias Scape.Init, as: ScapeInit
  alias TrainSwarmProc.QueueScape.CmdV1, as: QueueScape
  alias Schema.Vector, as: Vector

  require Logger

  def interested?(%Configured{} = event), do: {:start, event}
  def interested?(%Paid{} = event), do: {:start, event}
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
    # new_activation =
    #   if not Map.keys(activation) |> Enum.member?(:dimensions) do
    #     activation
    #     |> Map.put(:dimensions,Vector.default_map_dimensions() )
    #   else
    #     activation
    #   end

    {:ok, scape_init} = ScapeInit.from_map(%ScapeInit{dimensions: Vector.default_map_dimensions()}, activation)

    %QueueScape{agg_id: agg_id, payload: scape_init}
  end
end
