defmodule TrainSwarmProc.Initialize.ToPostgresDoc do
  use Commanded.Event.Handler,
    name: "TrainSwarmProc.Initialize.ToPostgresDoc.V1",
    application: TrainSwarmProc.CommandedApp,
    start_from: :origin

  alias TrainSwarmProc.Initialize.Evt,
    as: Initialized

  
  require Logger

  @impl true
  def handle(
        %Initialized{
          agg_id: agg_id,
          payload: payload
        } = evt,
        metadata
      ) do
    Logger.alert("TrainSwarmProc.Initialize.ToPostgresDoc: handle")
    Logger.alert("TrainSwarmProc.Initialize.ToPostgresDoc: agg_id: #{inspect(agg_id)}")
    Logger.alert("TrainSwarmProc.Initialize.ToPostgresDoc: payload: #{inspect(payload)}")
    Logger.alert("TrainSwarmProc.Initialize.ToPostgresDoc: metadata: #{inspect(metadata)}")
    {:ok, evt}
  end
end
