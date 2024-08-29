defmodule TrainSwarmProc.Router do
  use Commanded.Commands.Router

  alias TrainSwarmProc.Aggregate, as: Aggregate

  alias TrainSwarmProc.InitializeLicense.CmdV1, as: InitializeLicense
  alias TrainSwarmProc.InitializeLicense.Evaluator, as: InitializeLicenseHandler

  alias TrainSwarmProc.ConfigureLicense.CmdV1, as: ConfigureLicense
  alias TrainSwarmProc.ConfigureLicense.Evaluator, as: ConfigureLicenseHandler

  alias TrainSwarmProc.PayLicense.CmdV1, as: PayLicense
  alias TrainSwarmProc.PayLicense.Evaluator, as: PayLicenseHandler

  alias TrainSwarmProc.ActivateLicense.CmdV1, as: ActivateLicense
  alias TrainSwarmProc.ActivateLicense.Evaluator, as: ActivateLicenseHandler

  alias TrainSwarmProc.QueueLicense.CmdV1, as: QueueLicense
  alias TrainSwarmProc.QueueLicense.Evaluator, as: QueueLicenseHandler

  alias TrainSwarmProc.StartScape.CmdV1, as: StartScape
  alias TrainSwarmProc.StartScape.Evaluator, as: StartScapeHandler

  alias TrainSwarmProc.PauseScape.CmdV1, as: PauseScape
  alias TrainSwarmProc.PauseScape.Evaluator, as: PauseScapeHandler

  alias TrainSwarmProc.DetachScape.CmdV1, as: DetachScape
  alias TrainSwarmProc.DetachScape.Evaluator, as: DetachScapeHandler


  dispatch(InitializeLicense,
    to: InitializeLicenseHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(ConfigureLicense,
    to: ConfigureLicenseHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(PayLicense,
    to: PayLicenseHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(ActivateLicense,
    to: ActivateLicenseHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(QueueLicense,
    to: QueueLicenseHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(StartScape,
    to: StartScapeHandler,
    aggregate: Aggregate,
    identity: :agg_id
    )

  dispatch(DetachScape,
    to: DetachScapeHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )

  dispatch(PauseScape,
    to: PauseScapeHandler,
    aggregate: Aggregate,
    identity: :agg_id
  )


end
