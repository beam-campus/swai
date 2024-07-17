defmodule TrainSwarmProc.Configure.Projections do
  @moduledoc """
  This module is used to define the projections for the Release Right POC.
  """

  use GenServer

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  ################### PLUMBING ###################

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]}
    }
  end

  def start_link(_args) do
    children = [
      TrainSwarmProc.Configure.ToPostgresDoc,
      # ReleaseRightPoc.InitializeRRDoc.ToLog,
      # Starts a worker by calling: ReleaseRightPoc.Worker.start_link(arg)
      # {ReleaseRightPoc.Worker, arg}
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: TrainSwarmProc.Configure.Projections)

  end

end
