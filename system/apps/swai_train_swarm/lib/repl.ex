defmodule TrainSwarmProc.Repl do
  alias TrainSwarmProc.Initialize.EvtV1, as: Initialized
  alias TrainSwarmProc.Configure.EvtV1, as: Configured
  alias TrainSwarmProc.Initialize.CmdV1, as: Initialize
  alias TrainSwarmProc.Configure.CmdV1, as: Configure
  alias TrainSwarmProc.Initialize.PayloadV1, as: InitializePayload
  alias TrainSwarmProc.CommandedApp, as: TrainSwarmApp

  require Logger
  require UUID

  def try_initialize_swarm do
    payload = InitializePayload.new("some_user_id", "some_biotope_id", "some_biotope_name")
    cmd = %Initialize{agg_id: UUID.uuid4(), payload: payload}
    res = TrainSwarmApp.dispatch(cmd)
    # Logger.debug("Dispatched Initialize Command #{inspect(res)}")
  end
end
