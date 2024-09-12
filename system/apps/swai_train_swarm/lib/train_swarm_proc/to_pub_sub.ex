defmodule TrainSwarmProc.ToPubSubV1 do
  @moduledoc """
  This module is responsible for handling the events that are emitted by the TrainSwarmProc
  and broadcasting them to the Phoenix.PubSub
  """
  use Commanded.Event.Handler,
    name: __MODULE__,
    application: TrainSwarmProc.CommandedApp,
    start_from: :origin

  alias Swai.Accounts
  alias Commanded.PubSub
  alias Schema.User

  alias TrainSwarmProc.InitializeLicense.EvtV1, as: InitializedV1
  alias TrainSwarmProc.ConfigureLicense.EvtV1, as: ConfiguredV1
  alias TrainSwarmProc.PayLicense.EvtV1, as: LicensePaid

  alias TrainSwarmProc.ActivateLicense.EvtV1, as: LicenseActivated
  alias TrainSwarmProc.QueueLicense.EvtV1, as: LicenseQueued
  alias TrainSwarmProc.BlockLicense.EvtV1, as: LicenseBlocked

  alias TrainSwarmProc.InitializeLicenseScape.EvtV1, as: ScapeInitialized
  alias TrainSwarmProc.StartLicense.EvtV1, as: LicenseStarted
  alias TrainSwarmProc.PauseLicense.EvtV1, as: ScapePaused

  alias Scape.Facts, as: ScapeFacts
  alias License.Facts, as: LicenseFacts

  alias Phoenix.PubSub, as: PubSub

  require Logger

  @license_facts LicenseFacts.license_facts()
  @license_initialized LicenseFacts.license_initialized()
  @license_configured LicenseFacts.license_configured()
  @license_paid LicenseFacts.license_paid()
  @license_activated LicenseFacts.license_activated()
  @license_blocked LicenseFacts.license_blocked()

  @scape_facts ScapeFacts.scape_facts()
  @license_queued_v1 LicenseFacts.license_queued()
  @license_started_v1 LicenseFacts.license_started()
  @license_paused_v1 LicenseFacts.license_paused()

  # Event: License INITIALIZED 
  @impl true
  def handle(%InitializedV1{} = evt, metadata) do
    Logger.debug("INITIALIZED SWARM LICENSE with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast(@license_facts, {@license_initialized, evt, metadata})

    :ok
  end

  ####################### CONFIGURED #######################
  @impl true
  def handle(%ConfiguredV1{} = evt, metadata) do
    Logger.debug("CONFIGURING SWARM TRAINING with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@license_facts, {@license_configured, evt, metadata})

    :ok
  end

  ########################### LICENSE PAID ############################
  @impl true
  def handle(%LicensePaid{payload: %{user_id: user_id} = payment} = evt, metadata) do
    Logger.debug("LICENSE PAID with event #{inspect(evt)}")

    %User{email: user_email} = Accounts.get_user!(user_id)

    case String.contains?(user_email, "@discomco.pl") do
      true ->
        Logger.debug("User with email #{user_email} is from DisComCo and may swarm for free")

      false ->
        Accounts.decrease_user_budget(user_id, payment.cost_in_tokens)
    end

    Swai.PubSub
    |> PubSub.broadcast!(@license_facts, {@license_paid, evt, metadata})

    :ok
  end

  ############################## LICENSE ACTIVATED ##############################
  @impl true
  def handle(%LicenseActivated{} = evt, metadata) do
    Logger.debug("LICENSE ACTIVATED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@license_facts, {@license_activated, evt, metadata})

    :ok
  end

  ############################ LICENSE BLOCKED ############################
  @impl true
  def handle(%LicenseBlocked{} = evt, metadata) do
    Logger.debug("LICENSE BLOCKED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@license_facts, {@license_blocked, evt, metadata})

    :ok
  end

  ############################ SCAPE QUEUED ############################
  @impl true
  def handle(%LicenseQueued{} = evt, metadata) do
    Logger.debug("SCAPE QUEUED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@scape_facts, {@license_queued_v1, evt, metadata})

    :ok
  end

  ############################ SCAPE INITIALIZED #########################
  @impl true
  def handle(%ScapeInitialized{} = evt, metadata) do
    Logger.debug("SCAPE STARTED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@scape_facts, {@license_started_v1, evt, metadata})

    :ok
  end

  ################################ LICENSE STARTED ##############################
  @impl true
  def handle(%LicenseStarted{} = evt, metadata) do
    Logger.debug("License STARTED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@scape_facts, {@license_started_v1, evt, metadata})

    :ok
  end

  ############################ SCAPE PAUSED ############################
  @impl true
  def handle(%ScapePaused{} = evt, metadata) do
    Logger.debug("SCAPE PAUSED with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@scape_facts, {@license_paused_v1, evt, metadata})

    :ok
  end

  ####################### UNHANDLED EVENTS #######################
  @impl true
  def handle(msg, _metadata) do
    Logger.warning("Unhandled event #{inspect(msg)}")
    :ok
  end
end
