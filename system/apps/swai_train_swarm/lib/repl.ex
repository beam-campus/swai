defmodule TrainSwarmProc.Repl do


  alias TrainSwarmProc.Initialize.Evt, as: Initialized
  alias TrainSwarmProc.Configure.Evt, as: Configured
  alias TrainSwarmProc.Initialize.Cmd, as: Initialize
  alias TrainSwarmProc.Configure.Cmd, as: Configure
  alias TrainSwarmProc.Initialize.Payload, as: InitializePayload
  alias TrainSwarmProc.CommandedApp, as: TrainSwarmApp

  require Logger
  require UUID


  def try_initialize_swarm do
    payload = InitializePayload.new("some_user_id", "some_biotope_id")
    cmd = %Initialize{agg_id: UUID.uuid4(), payload: payload}
    res = TrainSwarmApp.dispatch(cmd)
    Logger.alert("Dispatched Initialize Command #{inspect(res)}")
  end

end
