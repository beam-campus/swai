defmodule TrainSwarmProc.Initialize.Handler do
  @moduledoc """
  Commanded handler for initializing the swarm training process.
  """

  @behaviour Commanded.Commands.Handler

  alias TrainSwarmProc.Initialize.Cmd,
    as: Initialize

  alias TrainSwarmProc.Aggregate,
    as: Aggregate

  @impl true
  def handle(%Aggregate{agg_id: nil, state: nil} = agg, %Initialize{} = cmd) do
    agg
    |> Aggregate.execute(cmd)
  end
end
