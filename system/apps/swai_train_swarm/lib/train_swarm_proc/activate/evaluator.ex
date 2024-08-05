defmodule TrainSwarmProc.Activate.Evaluator do
  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.Schema.Root, as: Root
  alias Schema.SwarmLicense, as: License
  alias TrainSwarmProc.Activate.CmdV1, as: Activate
  alias TrainSwarmProc.Activate.EvtV1, as: Activated
  alias TrainSwarmProc.Activate.PayloadV1, as: ActivatePayload

  alias TrainSwarmProc.Aggregate, as: Aggregate

  @impl Commanded.Commands.Handler
  def handle(
        %Aggregate{state: %Root{swarm_license: %License{} = license}} = _agg,
        %Activate{} = cmd
      ) do
    raise_activated(cmd)
  end

  defp raise_activated(cmd) do
    case Activated.from_map(%Activated{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
