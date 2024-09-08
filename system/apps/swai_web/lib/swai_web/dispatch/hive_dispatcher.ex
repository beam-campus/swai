defmodule SwaiWeb.HiveDispatcher do
  @moduledoc false
  alias Commanded.PubSub

  require Logger
  require Phoenix.PubSub, as: PubSub

  alias Hive.Facts, as: HiveFacts
  alias Swai.PubSub, as: SwaiPubSub
  alias Hive.Init, as: HiveInit
  alias Licenses.Service, as: Licenses

  @hive_facts HiveFacts.hive_facts()
  @hive_initialized_v1 HiveFacts.hive_initialized_v1()
  @hive_occupied_v1 HiveFacts.hive_occupied_v1()
  @hive_vacated_v1 HiveFacts.hive_vacated_v1()

  ## Reserve a license for a hive
  def try_reserve_license(envelope) do
    Logger.alert("HiveDispatcher.try_reserve_license: #{inspect(envelope)}")

    case HiveInit.from_map(%HiveInit{}, envelope["hive_init"]) do
      {:ok, hive_init} ->
        Licenses.try_reserve_license(hive_init)

      {:error, changeset} ->
        Logger.error("invalid envelope, reason: #{inspect(changeset)}")
        nil
    end
  end

  ######## HIVE INITIALIZED ########
  def pub_hive_initialized(envelope) do
    case HiveInit.from_map(%HiveInit{}, envelope["hive_init"]) do
      {:ok, hive_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(@hive_facts, {@hive_initialized_v1, hive_init})

      {:error, changeset} ->
        Logger.error("invalid envelope, reason: #{inspect(changeset)}")
        {:error, "invalid hive_init"}
    end
  end

  ######## HIVE OCCUPIED ########
  def pub_hive_occupied(envelope) do
    case HiveInit.from_map(%HiveInit{}, envelope["hive_init"]) do
      {:ok, hive_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(@hive_facts, {@hive_occupied_v1, hive_init})

      {:error, changeset} ->
        Logger.error("invalid envelope, reason: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  ######## HIVE VACATED ########
  def pub_hive_vacated(envelope) do
    case HiveInit.from_map(%HiveInit{}, envelope["hive_init"]) do
      {:ok, hive_init} ->
        SwaiPubSub
        |> PubSub.broadcast!(@hive_facts, {@hive_vacated_v1, hive_init})

      {:error, changeset} ->
        Logger.error("invalid envelope, reason: #{inspect(changeset)}")
        {:error, changeset}
    end
  end
end
