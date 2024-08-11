defmodule TrainSwarmProc.Aggregate do
  @moduledoc """
  This module defines the aggregate for the Train Swarm Process.
  """
  use Ecto.Schema

  alias TrainSwarmProc.Aggregate, as: Aggregate
  alias TrainSwarmProc.Schema.Root, as: Root
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: Status

  alias TrainSwarmProc.Initialize.EvtV1, as: Initialized
  alias TrainSwarmProc.Initialize.PayloadV1, as: Initialization

  alias TrainSwarmProc.Configure.EvtV1, as: Configured
  alias TrainSwarmProc.Configure.PayloadV1, as: Configuration

  alias TrainSwarmProc.PayLicense.EvtV1, as: Paid
  alias TrainSwarmProc.PayLicense.PayloadV1, as: Payment
  alias TrainSwarmProc.PayLicense.BudgetReachedV1, as: BudgetReached
  alias TrainSwarmProc.PayLicense.BudgetInfoV1, as: BudgetInfo

  alias TrainSwarmProc.Activate.EvtV1, as: LicenseActivated
  alias TrainSwarmProc.Activate.PayloadV1, as: Activation

  alias TrainSwarmProc.BlockLicense.CmdV1, as: BlockLicense
  alias TrainSwarmProc.BlockLicense.PayloadV1, as: BlockInfo
  alias TrainSwarmProc.BlockLicense.EvtV1, as: LicenseBlocked

  alias TrainSwarmProc.QueueScape.EvtV1, as: ScapeQueued
  alias Scape.Init, as: ScapeInit

  require Jason.Encoder
  require Logger

  @proc_unknown Status.unknown()
  @license_initialized_status Status.license_initialized()
  @license_configured_status Status.license_configured()
  @license_paid_status Status.license_paid()
  @license_active_status Status.license_active()
  @license_blocked_status Status.license_blocked()

  @scape_queued_status Status.scape_queued()



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
        %Initialized{} = evt
      ) do
    {:ok, new_license} = SwarmLicense.from_map(%SwarmLicense{}, evt.payload)

    new_license = %SwarmLicense{
      new_license
      | status: @license_initialized_status
    }

    %Aggregate{
      agg_id: evt.agg_id,
      status: @license_initialized_status,
      state: %Root{
        swarm_license: new_license
      }
    }
  end

  def apply(
        %Aggregate{state: %Root{swarm_license: license} = state} = agg,
        %Configured{payload: configuration} = _evt
      ) do
    {:ok, new_license} = SwarmLicense.from_map(license, configuration)

    new_license = %SwarmLicense{new_license | status: @license_configured_status}

    %Aggregate{
      agg
      | status: @license_configured_status,
        state: %Root{state | swarm_license: new_license}
    }
  end

  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %Paid{payload: payment} = _evt
      ) do
    {:ok, new_license} = SwarmLicense.from_map(license, payment)

    new_license = %SwarmLicense{new_license | status: @license_paid_status}

    %Aggregate{
      agg
      | status: @license_paid_status,
        state: %Root{root | swarm_license: new_license}
    }
  end

  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %LicenseActivated{payload: activation} = _evt
      ) do
    {:ok, new_license} = SwarmLicense.from_map(license, activation)

    new_license = %SwarmLicense{new_license | status: @license_active_status}

    %Aggregate{
      agg
      | status: @license_active_status,
        state: %Root{root | swarm_license: new_license}
    }
  end


  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %ScapeQueued{payload: scape} = _evt
      ) do
    {:ok, new_license} = SwarmLicense.from_map(license, scape)

    new_license = %SwarmLicense{new_license | status: @scape_queued_status}

    %Aggregate{
      agg
      | status: @scape_queued_status,
        state: %Root{root | swarm_license: new_license}
    }
  end


  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %LicenseBlocked{payload: block_info} = _evt
      ) do
    {:ok, new_license} = SwarmLicense.from_map(license, block_info)

    new_license = %SwarmLicense{new_license | status: @license_blocked_status}

    %Aggregate{
      agg
      | status: @license_blocked_status,
        state: %Root{root | swarm_license: new_license}
    }
  end





  def apply(agg, evt) do
    Logger.warning("Unknown event => #{inspect(evt)}")
    agg
  end
end
