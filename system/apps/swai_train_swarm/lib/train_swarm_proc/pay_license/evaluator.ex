defmodule TrainSwarmProc.PayLicense.Evaluator do
  @moduledoc """
  This module is responsible for evaluating the license of the user.
  """
  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.Schema.Root, as: Root
  alias Schema.SwarmLicense, as: License

  alias TrainSwarmProc.Aggregate, as: Aggregate

  alias TrainSwarmProc.PayLicense.PayloadV1, as: Payment
  alias TrainSwarmProc.PayLicense.CmdV1, as: PayLicense
  alias TrainSwarmProc.PayLicense.EvtV1, as: LicensePaid

  @impl Commanded.Commands.Handler
  def handle(
        %Aggregate{state: %Root{swarm_license: %License{} = license}} = _agg,
        %PayLicense{agg_id: agg_id, payload: payment} = cmd
      ) do
    reserve =
      payment.available_tokens +
        license.tokens_balance -
        payment.cost_in_tokens

    if reserve >= 0 do
      raise_license_paid(cmd)
    else
      {:error, :insufficient_funds}
    end
  end

  defp raise_license_paid(cmd) do
    case LicensePaid.from_map(%LicensePaid{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
