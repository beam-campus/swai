defmodule TrainSwarm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application, otp_app: :swai_train_swarm

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: TrainSwarm.Worker.start_link(arg)
      # {TrainSwarm.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TrainSwarm.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
