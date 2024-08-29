defmodule SwaiWeb.Dispatch.ScapeHandler do
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
  def pub_initializing_scape_v1(scape_init_env, socket) do
    case ScapeInit.from_map(%ScapeInit{}, scape_init_env["scape_init"]) do
      {:ok, scape_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@initializing_scape_v1, scape_init})

      {:error, reason} ->
        Logger.error("invalid scape_init, reason: #{inspect(reason)}")
        {:error, "invalid scape_init"}
    end

    {:noreply, socket}
  end

  ########################## SCAPE INITIALIZED ##########################
  def pub_scape_initialized_v1(scape_init_env, socket) do
    Logger.alert("pub_scape_initialized_v1: #{inspect(scape_init_env)}")

    case ScapeInit.from_map(%ScapeInit{}, scape_init_env["scape_init"]) do
      {:ok, scape_init} ->

        start_scape =
          %StartScape{
            agg_id: scape_init.license_id,
            version: 1,
            payload: scape_init
          }

        ProcApp.dispatch(start_scape)

        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@scape_initialized_v1, scape_init}
        )

      {:error, reason} ->
        Logger.error("invalid scape_init, reason: #{inspect(reason)}")
        {:error, "invalid scape_init"}
    end

    {:noreply, socket}
  end


  ####################### SCAPE STARTED #######################
  def pub_scape_started_v1(scape_init_env, socket) do
    Logger.alert("pub_scape_started_v1: #{inspect(scape_init_env)}")

    case ScapeInit.from_map(%ScapeInit{}, scape_init_env["scape_init"]) do
      {:ok, scape_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@scape_started_v1, scape_init}
        )

      {:error, _} ->
        Logger.error("pub_scape_started_v1: invalid scape_init")
        {:error, "invalid scape_init"}
    end

    {:noreply, socket}
  end


  ########################## SCAPE DETACHED ##########################
  def pub_scape_detached_v1(scape_init_env, socket) do
    case ScapeInit.from_map(%ScapeInit{}, scape_init_env["scape_init"]) do
      {:ok, scape_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(
          @scape_facts,
          {@scape_detached_v1, scape_init}
        )

        detach_scape =
          %DetachScape{
            agg_id: scape_init.license_id,
            version: 1,
            payload: scape_init
          }

          ProcApp.dispatch(detach_scape)

      {:error, _} ->
        Logger.error("pub_scape_detached_v1: invalid scape_init")
        {:error, "invalid scape_init"}
    end

    {:noreply, socket}
  end
end
