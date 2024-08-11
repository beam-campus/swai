defmodule TrainSwarmProc.BlockLicense.Evaluator do

  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.BlockLicense.CmdV1, as: BlockLicense
  alias TrainSwarmProc.BlockLicense.EvtV1, as: LicenseBlocked
  alias TrainSwarmProc.BlockLicense.PayloadV1, as: BlockInfo

  alias TrainSwarmProc.Aggregate, as: Aggregate

  @impl Commanded.Commands.Handler
  def handle(
        %Aggregate{} = _agg,
        %BlockLicense{} = cmd
      ) do
    raise_blocked(cmd)
  end

  defp raise_blocked(%BlockLicense{} = cmd) do
    case LicenseBlocked.from_map(%LicenseBlocked{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end



end
