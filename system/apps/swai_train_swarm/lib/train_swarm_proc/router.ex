defmodule TrainSwarmProc.Router do
  use Commanded.Commands.Router

  alias TrainSwarmProc.Aggregate, as: Aggregate

  alias TrainSwarmProc.Initialize.CmdV1, as: Initialize
  alias TrainSwarmProc.Initialize.Evaluator, as: InitializeHandler

  alias TrainSwarmProc.Configure.CmdV1, as: Configure
  alias TrainSwarmProc.Configure.Evaluator, as: ConfigureHandler

  alias TrainSwarmProc.PayLicense.CmdV1, as: PayLicense
  alias TrainSwarmProc.PayLicense.Evaluator, as: PayLicenseHandler

  alias TrainSwarmProc.Activate.CmdV1, as: Activate
  alias TrainSwarmProc.Activate.Evaluator, as: ActivateHandler

  alias TrainSwarmProc.QueueScape.CmdV1, as: QueueScape
  alias TrainSwarmProc.QueueScape.Evaluator, as: QueueScapeHandler


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

  dispatch(PayLicense,
    to: PayLicenseHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(Activate,
    to: ActivateHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(QueueScape,
    to: QueueScapeHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )


end
