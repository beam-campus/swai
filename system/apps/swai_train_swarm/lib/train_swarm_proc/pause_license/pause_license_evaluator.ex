defmodule TrainSwarmProc.PauseLicense.Evaluator do
  @moduledoc """
  The evaluator for the PauseLicense process.
  """

  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.PauseLicense.EvtV1, as: LicensePaused
  alias TrainSwarmProc.PauseLicense.CmdV1, as: PauseLicense

  require Logger

  @impl Commanded.Commands.Handler
  def handle(_agg, %PauseLicense{} = cmd) do
    raise_scape_paused(cmd)
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
