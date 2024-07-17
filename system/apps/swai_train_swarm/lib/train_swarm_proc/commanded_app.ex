defmodule TrainSwarmProc.CommandedApp do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Commanded.Application, otp_app: :swai_train_swarm
  @behaviour Application

  @impl true
  def init(config) do
    {:ok, config}
  end

  router(TrainSwarmProc.Router)

  @impl true
  def start(_type, _args) do

    children = [
      TrainSwarmProc.Initialize.Projections,
      TrainSwarmProc.Configure.Projections,
    ]
    Supervisor.start_link(children, [strategy: :one_for_one, name: TrainSwarmProc.Supervisor])
  end
end
