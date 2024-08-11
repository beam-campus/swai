defmodule TrainSwarmProc.ToPubSubV1 do
  @moduledoc """
  This module is responsible for handling the events that are emitted by the TrainSwarmProc
  and broadcasting them to the Phoenix.PubSub
  """
  use Commanded.Event.Handler,
    name: "TrainSwarmProc.ToPubSubV1",
    application: TrainSwarmProc.CommandedApp,
    start_from: :origin

  alias Commanded.PubSub

  alias TrainSwarmProc.Initialize.EvtV1, as: InitializedV1
  alias TrainSwarmProc.Configure.EvtV1, as: ConfiguredV1
  alias TrainSwarmProc.PayLicense.EvtV1, as: LicensePaid
  alias TrainSwarmProc.Activate.EvtV1, as: LicenseActivated
  alias TrainSwarmProc.QueueScape.EvtV1, as: ScapeQueued
  alias TrainSwarmProc.BlockLicense.EvtV1, as: LicenseBlocked


  alias TrainSwarmProc.Facts, as: Facts
  alias Phoenix.PubSub, as: PubSub

  require Logger

  @initialized_v1 Facts.license_initialized()
  @configured_v1 Facts.license_configured()
  @license_paid Facts.license_paid()
  @license_activated Facts.license_activated()
  @license_blocked Facts.license_blocked()

  @scape_queued Facts.scape_queued()

  ###################### INITIALIZED #######################
  @impl true
  def handle(%InitializedV1{} = evt, metadata) do
    Logger.debug("INITIALIZING SWARM TRAINING with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast(@initialized_v1, {@initialized_v1, evt, metadata})

    :ok
  end

  ####################### CONFIGURED #######################
  @impl true
  def handle(%ConfiguredV1{} = evt, metadata) do
    Logger.debug("CONFIGURING SWARM TRAINING with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@configured_v1, {@configured_v1, evt, metadata})

    :ok
  end

  ########################### LICENSE PAID ############################
  @impl true
  def handle(%LicensePaid{} = evt, metadata) do
    Logger.debug("LICENSE PAID with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@license_paid, {@license_paid, evt, metadata})

    :ok
  end

  ############################## LICENSE ACTIVATED ##############################
  @impl true
  def handle(%LicenseActivated{} = evt, metadata) do
    Logger.debug("LICENSE ACTIVATED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@license_activated, {@license_activated, evt, metadata})

    :ok
  end

  ############################ SCAPE QUEUED ############################
  @impl true
  def handle(%ScapeQueued{} = evt, metadata) do
    Logger.debug("SCAPE QUEUED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@scape_queued, {@scape_queued, evt, metadata})

    :ok
  end

  ############################ LICENSE BLOCKED ############################
  @impl true
  def handle(%LicenseBlocked{} = evt, metadata) do
    Logger.debug("LICENSE BLOCKED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@license_blocked, {@license_blocked, evt, metadata})

    :ok
  end

  ####################### UNHANDLED EVENTS #######################
  @impl true
  def handle(msg, _metadata) do
    Logger.warning("Unhandled event #{inspect(msg)}")
    {:error, "Unhandled event #{inspect(msg)}"}
  end
end
