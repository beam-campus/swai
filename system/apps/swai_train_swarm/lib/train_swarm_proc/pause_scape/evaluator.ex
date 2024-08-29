defmodule TrainSwarmProc.PauseScape.Evaluator do
  @moduledoc """
  The evaluator for the PauseScape process.
  """

  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.PauseScape.EvtV1, as: ScapePaused
  alias TrainSwarmProc.PauseScape.CmdV1, as: PauseScape


  require Logger


  @impl Commanded.Commands.Handler
  def handle(_agg, %PauseScape{} = cmd) do
    raise_scape_paused(cmd)
  end

  defp raise_scape_paused(cmd) do
    case ScapePaused.from_map(%ScapePaused{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end




end
