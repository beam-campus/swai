defmodule TrainSwarmProc.Configure.ToPostgresDoc do
  use Commanded.Event.Handler,
    name: "TrainSwarmProc.Configure.ToPostgresDoc.V1",
    application: TrainSwarmProc.CommandedApp,
    start_from: :origin


    alias TrainSwarmProc.Configure.Evt,
    as: Configured

    require Logger

    @impl true
    def handle(%Configured{
      agg_id: agg_id,
      payload: payload
      } = evt, metadata) do
      Logger.info("TrainSwarmProc.Configure.ToPostgresDoc: handle")
      Logger.info("TrainSwarmProc.Configure.ToPostgresDoc: agg_id: #{inspect(agg_id)}")
      Logger.info("TrainSwarmProc.Configure.ToPostgresDoc: payload: #{inspect(payload)}")
      Logger.info("TrainSwarmProc.Configure.ToPostgresDoc: metadata: #{inspect(metadata)}")
      {:ok, evt}
    end




end
