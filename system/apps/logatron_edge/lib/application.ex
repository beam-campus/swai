defmodule Edge.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
    Edge.Application is the main application for the Logatron Edge.
  """
  use Application

  require Logger

  alias Edge.Init, as: EdgeInit
  alias Scape.Init, as: ScapeInit

  @default_edge_id Logatron.Core.constants()[:edge_id]

  def edge_id,
    do: @default_edge_id

  @impl Application
  def start(_type, _args) do

    edge_init = EdgeInit.enriched()

    IO.puts("\n\n\n
    +---------------------------------+
    |           LOGATRON EDGE         |
    |           DAIRY FARM            |
    +---------------------------------+

    edge_id:\t#{edge_init.id}
    scape_id:\t#{edge_init.scape_id}
    api_key:\t#{edge_init.api_key}
    country:\t#{edge_init.country}

    \n\n\n")

    Process.sleep(5_000)

    children = [
      {Edge.Registry, name: Edge.Registry},
      {Phoenix.PubSub, name: EdgePubSub},
      {Edge.Client, edge_init}
    ]

    Supervisor.start_link(
      children,
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  @impl Application
  def stop(scape_init) do
    Scape.System.terminate(:normal, scape_init)
    Supervisor.stop(__MODULE__)
  end

  def start_scape(edge_id) do
    scape_init = ScapeInit.from_environment(edge_id)

    Supervisor.start_child(
      __MODULE__,
      {Scape.System, scape_init}
    )
  end

end
