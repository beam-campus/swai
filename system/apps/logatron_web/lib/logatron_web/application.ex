defmodule LogatronWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Edge.Registry, name: Edge.Registry},
      LogatronWeb.Telemetry,
      LogatronWeb.Dispatch.EdgePresence,

      {LogatronWeb.Dispatch.ChannelWatcher, "edge:lobby"},
      LogatronWeb.Endpoint,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LogatronWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LogatronWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
