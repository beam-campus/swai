defmodule TrainSwarmProc.Configure.Evaluator do
  @moduledoc """
  Commanded handler for configuring the swarm training process.
  """
  @behaviour Commanded.Commands.Handler

  alias Schema.SwarmLicense.Status, as: Status
  alias TrainSwarmProc.Configure.CmdV1, as: Configure
  alias TrainSwarmProc.Configure.EvtV1, as: Configured
  alias TrainSwarmProc.Schema.Root, as: Root
  alias TrainSwarmProc.Aggregate, as: Aggregate

  import Flags

  @proc_initialized Status.license_initialized()

  @impl true
  def handle(
        %Aggregate{status: status},
        %Configure{} = cmd
      ) do
    if status
       |> has?(@proc_initialized) do
      raise_configured(cmd)
    else
      {:error, :not_initialized}
    end
  end

  defp raise_configured(cmd) do
    case Configured.from_map(%Configured{}, cmd) do
      {:ok, evt} ->
        evt

      {:error, reason} ->
        {:error, reason}
    end
  end
end
