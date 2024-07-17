defmodule TrainSwarmProc do
  @moduledoc """
  Documentation for `TrainSwarm`.
  """

  @prefix "train-swarm"

  alias TrainSwarmProc.Initialize.Payload,
    as: LicenseRequest

  alias TrainSwarmProc.CommandedApp,
    as: TrainSwarmApp

  alias TrainSwarmProc.Initialize.Cmd,
    as: Initialize

  alias Schema.Id, as: Id

  require Logger

  @doc """
  Hello world.

  ## Examples

      iex> TrainSwarm.hello()
      :world

  """

  def change_license_request(%LicenseRequest{} = root, %{} = map) do
    root
    |> LicenseRequest.changeset(map)
  end

  def initialize(%{} = license_request_params) do
    Logger.alert("Initializing License Request #{inspect(license_request_params)}")

    case LicenseRequest.from_map(license_request_params) do
      {:ok, payload} ->

        agg_id = UUID.uuid4()

        cmd = %Initialize{
          agg_id: agg_id,
          payload: payload
        }

        res = TrainSwarmApp.dispatch(cmd)

        Logger.alert("Dispatched Initialize Command #{inspect(res)}")

        res

      {:error, changeset} ->
        Logger.error("Invalid license request params #{inspect(changeset)}")
        {:error, "Invalid license request params #{inspect(changeset)}"}
    end
  end
end
