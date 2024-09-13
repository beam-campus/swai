defmodule TrainSwarmProc.PauseLicense.Evaluator do
  @moduledoc """
  The evaluator for the PauseLicense process.
  """
  @behaviour Commanded.Commands.Handler

  import Flags

  alias Schema.SwarmLicense.Status, as: LicenseStatus
  alias TrainSwarmProc.PauseLicense.CmdV1, as: PauseLicense
  alias TrainSwarmProc.PauseLicense.EvtV1, as: LicensePaused

  require Logger

  @license_started LicenseStatus.license_started()

  @impl Commanded.Commands.Handler
  def handle(%{status: status} = _agg, %PauseLicense{} = cmd) do
    if status |> has?(@license_started) do
      Logger.info("PauseLicense: pausing license")
      raise_scape_paused(cmd)
    else
      Logger.error("PauseLicense: license not started")
      {:error, "License not started"}
    end
  end

  defp raise_scape_paused(cmd) do
    case LicensePaused.from_map(%LicensePaused{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
