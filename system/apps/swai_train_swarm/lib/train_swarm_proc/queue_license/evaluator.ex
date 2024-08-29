defmodule TrainSwarmProc.QueueLicense.Evaluator do
  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.QueueLicense.CmdV1, as: QueueLicense
  alias TrainSwarmProc.QueueLicense.EvtV1, as: ScapeQueued
  alias Scape.Init, as: ScapeInit

  alias TrainSwarmProc.Aggregate, as: Aggregate
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: Status

  @license_active_status Status.license_active()

  @impl Commanded.Commands.Handler
  def handle(
        %Aggregate{} = agg,
        %QueueLicense{} = cmd
      ) do
    if agg.status |> Flags.has?(@license_active_status) do
      raise_queued(cmd)
    else
      {:error, "License not active"}
    end
  end

  defp raise_queued(%QueueLicense{} = cmd) do
    case ScapeQueued.from_map(%ScapeQueued{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
