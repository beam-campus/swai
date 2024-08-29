defmodule TrainSwarmProc.StartScape.Evaluator do
  @moduledoc """
  This module is responsible for evaluating the start of a scape.
  """
  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.StartScape.CmdV1, as: StartScape
  alias TrainSwarmProc.StartScape.EvtV1, as: ScapeStarted
  alias TrainSwarmProc.Aggregate, as: Agg

  alias Schema.SwarmLicense.Status, as: Status

  @scape_paused Status.scape_paused()
  @scape_queued Status.scape_queued()


  import Flags

  @impl Commanded.Commands.Handler
  def handle(%Agg{status: status}, %StartScape{} = cmd) do
    if status |> has_any?([@scape_paused, @scape_queued]) do
      raise_scape_started(cmd)
    else
      {:error, "A Scape must be paused or queued to start it."}
    end
  end

  defp raise_scape_started(cmd) do
    case ScapeStarted.from_map(%ScapeStarted{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
