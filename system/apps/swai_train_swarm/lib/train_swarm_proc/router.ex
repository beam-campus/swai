defmodule TrainSwarmProc.Router do
  use Commanded.Commands.Router

  alias TrainSwarmProc.Aggregate,
    as: Aggregate

  alias TrainSwarmProc.Initialize.Cmd.V1,
    as: Initialize

  alias TrainSwarmProc.Initialize.Evaluator,
    as: InitializeHandler


  alias TrainSwarmProc.Configure.Cmd.V1,
  as: Configure

  alias TrainSwarmProc.Configure.Evaluator,
  as: ConfigureHandler


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
