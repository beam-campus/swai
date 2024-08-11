defmodule SwaiAco.EdgeApp do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
    Edge.Application is the main application for the Swai Edge.
  """
  use Application, otp_app: :swai_aco

  require Logger

  alias Edge.Init, as: EdgeInit
  alias Scape.Init, as: ScapeInit

  @planet_of_ants_id "b105f59e-42ce-4e85-833e-d123e36ce943"
  @biotope_id @planet_of_ants_id

  @biotope_name "Planet of Ants"
  @algorithm_acronym "ACO"

  @impl Application
  def start(_type, _args) do
    %EdgeInit{} = edge_init = EdgeInit.enriched()

    edge_init =
      %EdgeInit{
        edge_init
        | biotope_id: @biotope_id,
          biotope_name: @biotope_name,
          algorithm_acronym: @algorithm_acronym
      }

    IO.puts("\n\n\n
    +----------------------------------------------+
    |           ANT COLONY OPTIMIZATION            |
    +----------------------------------------------+

    edge_id:\t#{edge_init.id}
    biotope_name:\t#{edge_init.biotope_name}
    algorithm_acronym:\t#{edge_init.algorithm_acronym}
    api_key:\t#{edge_init.api_key}
    country:\t#{edge_init.country}

    \n\n\n")

    Process.sleep(2_000)

    children = [
      {Swai.Registry, name: Edge.Registry},
      {Phoenix.PubSub, name: Edge.PubSub},
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

  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start, []}
    }
  end

  def start_scape(edge_id) do
    scape_init = ScapeInit.from_environment(edge_id)

    Supervisor.start_child(
      __MODULE__,
      {Scape.System, scape_init}
    )
  end
end
