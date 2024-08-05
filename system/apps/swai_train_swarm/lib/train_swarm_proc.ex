defmodule TrainSwarmProc do
  @moduledoc """
  TrainSwarmProc is the context module for the TrainSwarm aggregate/process.
  """

  alias Schema.SwarmLicense, as: SwarmLicense

  alias TrainSwarmProc.CommandedApp, as: TrainSwarmApp
  alias TrainSwarmProc.Initialize.CmdV1, as: Initialize
  alias TrainSwarmProc.Initialize.PayloadV1, as: Initialization

  require Logger

  @agg_id "agg_id"
  @user_id "user_id"


  def change_swarm_license(%SwarmLicense{} = seed, %{} = map) do
    seed
    |> SwarmLicense.changeset(map)
  end

  def initialize(%{@agg_id => agg_id, @user_id => user_id} = license_request_params) do
    seed = %SwarmLicense{license_id: agg_id}

    case SwarmLicense.from_map(seed, license_request_params) do
      {:ok, license} ->
        {:ok, initialization} = Initialization.from_map(%Initialization{}, license)

        cmd = %Initialize{
          agg_id: agg_id,
          payload: initialization
        }

        TrainSwarmApp.dispatch(cmd, metadata: %{@user_id => user_id})

      {:error, changeset} ->
        {:error, "Invalid license request params #{inspect(changeset)}"}
    end
  end
end
