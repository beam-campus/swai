defmodule TrainSwarmProc.Repl do
  alias TrainSwarmProc.Initialize.Evt.V1, as: Initialized
  alias TrainSwarmProc.Configure.Evt.V1, as: Configured
  alias TrainSwarmProc.Initialize.Cmd.V1, as: Initialize
  alias TrainSwarmProc.Configure.Cmd.V1, as: Configure
  alias TrainSwarmProc.Initialize.Payload.V1, as: InitializePayload
  alias TrainSwarmProc.CommandedApp, as: TrainSwarmApp

  require Logger
  require UUID

  def try_initialize_swarm do
    payload = InitializePayload.new("some_user_id", "some_biotope_id", "some_biotope_name")
    cmd = %Initialize{agg_id: UUID.uuid4(), payload: payload}
    res = TrainSwarmApp.dispatch(cmd)
    # Logger.alert("Dispatched Initialize Command #{inspect(res)}")
  end
end
