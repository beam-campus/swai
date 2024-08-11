defmodule TrainSwarmProc.PayLicense.Evaluator do
  @moduledoc """
  This module is responsible for evaluating the license of the user.
  """
  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.PayLicense.BudgetInfoV1
  alias TrainSwarmProc.Schema.Root, as: Root
  alias Schema.SwarmLicense, as: License

  alias TrainSwarmProc.Aggregate, as: Aggregate

  alias TrainSwarmProc.PayLicense.CmdV1, as: PayLicense
  alias TrainSwarmProc.PayLicense.EvtV1, as: LicensePaid
  alias TrainSwarmProc.PayLicense.BudgetReachedV1, as: BudgetReached

  @impl Commanded.Commands.Handler
  def handle(
        %Aggregate{state: %Root{swarm_license: %License{} = license}} = _agg,
        %PayLicense{payload: payment} = cmd
      ) do
    current_budget = payment.available_tokens + license.tokens_balance
    required_budget = payment.cost_in_tokens

    reserve = current_budget - required_budget

    if reserve >= 0 do
      raise_license_paid(cmd)
    else
      raise_budget_reached(current_budget, required_budget, cmd)
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

  defp raise_budget_reached(current_budget, required_budget, cmd) do
    seed = %BudgetReached{
      payload: %BudgetInfoV1{
        current_budget: current_budget,
        required_budget: required_budget
      }
    }

    case BudgetReached.from_map(seed, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
