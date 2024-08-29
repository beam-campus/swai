defmodule TrainSwarmProc.Aggregate do
  @moduledoc """
  This module defines the aggregate for the Train Swarm Process.
  """
  use Ecto.Schema

  alias TrainSwarmProc.Aggregate, as: Aggregate
  alias TrainSwarmProc.Schema.Root, as: Root
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: Status

  alias TrainSwarmProc.InitializeLicense.EvtV1, as: LicenseInitialized

  alias TrainSwarmProc.ConfigureLicense.EvtV1, as: Configured
  alias Schema.SwarmLicense, as: Configuration

  alias TrainSwarmProc.PayLicense.EvtV1, as: LicensePaid
  alias Schema.SwarmLicense, as: Payment
  alias TrainSwarmProc.PayLicense.BudgetReachedV1, as: BudgetReached
  alias TrainSwarmProc.PayLicense.BudgetInfoV1, as: BudgetInfo

  alias TrainSwarmProc.ActivateLicense.EvtV1, as: LicenseActivated
  alias TrainSwarmProc.BlockLicense.EvtV1, as: LicenseBlocked

  alias TrainSwarmProc.QueueLicense.EvtV1, as: ScapeQueued
  alias TrainSwarmProc.StartScape.EvtV1, as: ScapeStarted
  alias TrainSwarmProc.PauseScape.EvtV1, as: ScapePaused
  alias TrainSwarmProc.DetachScape.EvtV1, as: ScapeDetached

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
  @scape_started_status Status.scape_started()
  @scape_paused_status Status.scape_paused()
  @scape_detached_status Status.scape_detached()

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

  ###################  LICENSE INITIALIZED  ###################
  def apply(
        %Aggregate{state: nil} = _agg,
        %LicenseInitialized{} = evt
      ) do
    case SwarmLicense.from_map(%SwarmLicense{}, evt.payload) do
      {:ok, new_license} ->
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

      {:error, changeset} ->
        Logger.error("invalid license INITIALIZATION

          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}

          ")
        {:error, "invalid license initialization"}
    end
  end

  ##################### LICENSE CONFIGURED #####################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = state} = agg,
        %Configured{payload: configuration} = evt
      ) do
    case SwarmLicense.from_map(license, configuration) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: @license_configured_status
        }

        %Aggregate{
          agg
          | status: @license_configured_status,
            state: %Root{state | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid license CONFIGURATION
          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}")
        {:error, "invalid license configuration"}
    end
  end

  ###################### LICENSE_BLOCKED ######################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %LicenseBlocked{payload: block_info} = evt
      ) do
    case SwarmLicense.from_map(license, block_info) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: @license_blocked_status
        }

        %Aggregate{
          agg
          | status: @license_blocked_status,
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid license BLOCKING

          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}

          ")
        {:error, "invalid license block"}
    end
  end

  ##################### LICENSE PAID #####################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %LicensePaid{payload: payment} = evt
      ) do
    case SwarmLicense.from_map(license, payment) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: @license_paid_status
        }

        %Aggregate{
          agg
          | status: @license_paid_status,
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid license PAYMENT

          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}

          ")
        {:error, "invalid license PAYMENT"}
    end
  end

  ##################### LICENSE ACTIVATED #####################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %LicenseActivated{payload: activation} = evt
      ) do
    case SwarmLicense.from_map(license, activation) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: @license_active_status
        }

        %Aggregate{
          agg
          | status: @license_active_status,
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error(
          "invalid license ACTIVATION \n\n event => \n#{inspect(evt)} \n\nchangeset => \n#{inspect(changeset)}"
        )

        {:error, "invalid license activation"}
    end
  end

  ####################### LICENSE BLOCKED #######################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %LicenseBlocked{payload: block_info} = evt
      ) do
    case SwarmLicense.from_map(license, block_info) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: license.status |> Flags.set(@license_blocked_status)
        }

        %Aggregate{
          agg
          | status: agg.status |> Flags.set(@license_blocked_status),
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid license block

          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}

          ")
        {:error, "invalid license block"}
    end
  end

  ####################### SCAPE QUEUED #######################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %ScapeQueued{payload: scape} = evt
      ) do
    case SwarmLicense.from_map(license, scape) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: @scape_queued_status
        }

        %Aggregate{
          agg
          | status: agg.status |> Flags.set(@scape_queued_status),
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid scape queued
          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}
          ")
        {:error, "invalid scape queued"}
    end
  end

  ####################### SCAPE STARTED #######################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %ScapeStarted{payload: scape} = evt
      ) do
    case SwarmLicense.from_map(license, scape) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: license.status |> Flags.set(@scape_started_status)
        }

        %Aggregate{
          agg
          | status: agg.status |> Flags.set(@scape_started_status),
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid scape started

          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}")
        {:error, "invalid scape started"}
    end
  end

  ############################ SCAPE DETACHED ############################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %ScapeDetached{payload: scape_init} = evt
      ) do
    scape_init =
      %ScapeInit{
        scape_init
        | id: scape_init.license_id
      }

    case SwarmLicense.from_map(license, scape_init) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status:
              license.status
              |> Flags.set(@scape_detached_status)
        }

        %Aggregate{
          agg
          | status:
              agg.status
              |> Flags.set(@scape_detached_status),
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid scape detached

          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}

          ")
        {:error, "invalid scape detached"}
    end
  end

  ########################### SCAPE PAUSED ###########################
  def apply(
        %Aggregate{state: %Root{swarm_license: license} = root} = agg,
        %ScapePaused{payload: pause_info} = evt
      ) do
    case SwarmLicense.from_map(license, pause_info) do
      {:ok, new_license} ->
        new_license = %SwarmLicense{
          new_license
          | status: license.status |> Flags.set(@scape_paused_status)
        }

        %Aggregate{
          agg
          | status: agg.status |> Flags.set(@scape_paused_status),
            state: %Root{root | swarm_license: new_license}
        }

      {:error, changeset} ->
        Logger.error("invalid scape paused

          event => #{inspect(evt)}

          changeset => #{inspect(changeset)}

          ")
        {:error, "invalid scape paused"}
    end
  end

  ####################### UNKNOWN EVENT #######################
  def apply(agg, evt) do
    Logger.warning("Unknown event => #{inspect(evt)}")
    agg
  end
end
