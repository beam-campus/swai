defmodule SwaiWeb.ScapeDispatcher do
  @moduledoc """
  The ScapeHandler is used to broadcast messages to all clients
  """

  alias Scape.Facts, as: ScapeFacts
  alias Scape.Init, as: ScapeInit

  alias Phoenix.PubSub, as: PubSub
  alias Swai.PubSub, as: SwaiPubSub

  alias TrainSwarmProc.StartScape.CmdV1, as: StartScape
  alias TrainSwarmProc.CommandedApp, as: ProcApp
  alias TrainSwarmProc.DetachScape.CmdV1, as: DetachScape

  require Logger

  @scape_facts ScapeFacts.scape_facts()
  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scape_initialized_v1 ScapeFacts.scape_initialized_v1()
  @scape_started_v1 ScapeFacts.scape_started_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()

  ########################## INITIALIZING SCAPE ##########################
  def pub_initializing_scape(envelope, _socket) do
    case ScapeInit.from_map(%ScapeInit{}, envelope["scape_init"]) do
      {:ok, scape_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@initializing_scape_v1, scape_init}
        )

      {:error, changeset} ->
        Logger.error("invalid envelope, reason: #{inspect(changeset)}")
        {:error, "invalid scape_init"}
    end
  end

  ########################## SCAPE INITIALIZED ##########################
  def pub_scape_initialized(envelope, _socket) do
    case ScapeInit.from_map(%ScapeInit{}, envelope["scape_init"]) do
      {:ok, scape_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@scape_initialized_v1, scape_init}
        )

      {:error, changeset} ->
        Logger.error("invalid scape_init, reason: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  ####################### SCAPE STARTED #######################
  def pub_scape_started(envelope, _socket) do
    case ScapeInit.from_map(%ScapeInit{}, envelope["scape_init"]) do
      {:ok, scape_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@scape_started_v1, scape_init}
        )

      {:error, changeset} ->
        Logger.error("invalid envelope: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  ########################## SCAPE DETACHED ##########################
  def pub_scape_detached(envelope, _socket) do
    case ScapeInit.from_map(%ScapeInit{}, envelope["scape_init"]) do
      {:ok, scape_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@scape_detached_v1, scape_init}
        )

      {:error, changeset} ->
        Logger.error("invalid envelope: #{inspect(changeset)}")
        {:error, changeset}
    end
  end
end
