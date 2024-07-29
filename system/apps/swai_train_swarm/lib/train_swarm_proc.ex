defmodule TrainSwarmProc do
  @moduledoc """
  TrainSwarmProc is the context module for the TrainSwarm aggregate/process.
  """

  @prefix "train-swarm"

  alias Schema.SwarmTraining, as: SwarmTraining
  alias TrainSwarmProc.CommandedApp, as: TrainSwarmApp
  alias TrainSwarmProc.Initialize.Cmd.V1, as: Initialize

  require Logger

  @agg_id "agg_id"
  @user_id "user_id"

  def change_swarm_training(%SwarmTraining{} = root, %{} = map) do
    root
    |> SwarmTraining.changeset(map)
  end

  def initialize(
    %{@agg_id => agg_id, @user_id => user_id} = license_request_params) do
    seed = %SwarmTraining{id: agg_id}

    case SwarmTraining.from_map(seed, license_request_params) do
      {:ok, payload} ->
        cmd = %Initialize{
          agg_id: agg_id,
          payload: payload
        }

        TrainSwarmApp.dispatch(cmd, metadata: %{@user_id => user_id} )

      {:error, changeset} ->
        Logger.error("Invalid license request params #{inspect(changeset)}")
        {:error, "Invalid license request params #{inspect(changeset)}"}
    end
  end
end
