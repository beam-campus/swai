defmodule SwaiWeb.Channels.Repl do
  @moduledoc """
  This module is used to send messages to the edge clients.
  """
  alias Schema.Vector
  alias Edges.Service, as: Edges
  alias SwaiWeb.EdgeChannel, as: EdgeChannel
  alias Scape.Init, as: ScapeInit
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: LicenseStatus
  alias Edge.Init, as: EdgeInit

  require Logger

  def try_start_scape() do
    %EdgeInit{} =
      edge_init =
      random_edge_init()

    Logger.info("Starting scape on edge: #{edge_init.id}")

    %SwarmLicense{} =
      license =
      edge_init
      |> random_license()

    Logger.info("Starting scape for license: #{license.license_id}")

    %ScapeInit{} =
      scape_init =
      license
      |> random_scape_init()

    Logger.info("Starting scape for scape: #{scape_init.id}")

    start_scape(edge_init, scape_init)
  end

  defp random_edge_init() do
    Edges.get_all()
    |> Enum.random()
  end

  defp start_scape(%EdgeInit{} = edge_init, %ScapeInit{} = scape_init) do
    Logger.info("Starting scape for edge: #{edge_init.biotope_name}")

    EdgeChannel.start_scape(edge_init, scape_init)
  end

  defp random_license(%EdgeInit{} = edge_init) do
    %SwarmLicense{
      license_id: UUID.uuid4(),
      swarm_id: UUID.uuid4(),
      swarm_name: "Random Swarm",
      swarm_size: 100,
      swarm_time_min: 10,
      available_tokens: 1000,
      user_id: UUID.uuid4(),
      biotope_id: edge_init.biotope_id,
      algorithm_id: "some_algorithm_id",
      algorithm_acronym: edge_init.algorithm_acronym,
      cost_in_tokens: 1000,
      status: LicenseStatus.license_paid()
    }
  end

  defp random_scape_init(%SwarmLicense{} = swarm_license) do
    %ScapeInit{
      id: UUID.uuid4(),
      name: "Random Scape",
      license_id: swarm_license.license_id,
      swarm_id: swarm_license.swarm_id,
      swarm_name: swarm_license.swarm_name,
      swarm_size: 10,
      swarm_time_min: 10,
      user_id: swarm_license.user_id,
      biotope_id: swarm_license.biotope_id,
      algorithm_id: swarm_license.algorithm_id,
      algorithm_acronym: swarm_license.algorithm_acronym,
      dimensions: %Vector{
        x: 100,
        y: 100,
        z: 0
      }
    }
  end
end
