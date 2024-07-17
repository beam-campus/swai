defmodule TrainSwarmProc.Router do
  use Commanded.Commands.Router

  alias TrainSwarmProc.Initialize.Cmd,
    as: Initialize



  alias TrainSwarmProc.Initialize.Handler,
    as: InitializeHandler

  alias TrainSwarmProc.Aggregate,
    as: Aggregate

  alias TrainSwarmProc.Configure.Cmd,  as: Configure


  alias TrainSwarmProc.Configure.Handler,
    as: ConfigureHandler

  alias TrainSwarmProc.Initialize.Payload,
    as: Payload


  # identity(Aggregate,
  #   by: :root_id,
  #   prefix: "release_right_poc"
  # )

  dispatch(Initialize,
    to: InitializeHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(Configure,
    to: ConfigureHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )
end
