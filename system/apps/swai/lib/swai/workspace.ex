defmodule Swai.Workspace do
  @moduledoc """
  The Workspace context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Swai.Repo
  alias Schema.SwarmLicense, as: SwarmLicense

  def exists_swarm_license?(id) do
    query = from(s in SwarmLicense, where: s.license_id == ^id)
    Repo.exists?(query)
  end

  def list_swarm_licenses do
    Repo.all(SwarmLicense)
  end

  def get_swarm_license!(id), do: Repo.get!(SwarmLicense, id)

  def create_swarm_license(attrs \\ %{}) do
    if exists_swarm_license?(attrs.id) do
      Logger.error("SwarmLicense already exists with id #{attrs.id}")
      {:error, "SwarmLicense already exists with id #{attrs.id}"}
    else
      case %SwarmLicense{}
           |> SwarmLicense.changeset(attrs) do
        %{valid?: true} = changeset ->
          changeset
          |> Repo.insert()
        changeset ->
          Logger.error("Invalid changeset: #{inspect(changeset)}")
          changeset
      end
    end
  end

  def update_swarm_license(%SwarmLicense{} = swarm_license, attrs) do
    Logger.warning("Updating swarm license #{inspect(swarm_license)} with attrs #{inspect(attrs)}")
    swarm_license
    |> SwarmLicense.changeset(attrs)
    |> Repo.update()
  end

  def delete_swarm_license(%SwarmLicense{} = swarm_license) do
    Repo.delete(swarm_license)
  end

  def change_swarm_license(%SwarmLicense{} = swarm_license, attrs \\ %{}) do
    SwarmLicense.changeset(swarm_license, attrs)
  end

  def get_swarm_licenses_by_user_id(user_id) do
    Repo.all(
      from(
        s in SwarmLicense,
        where: s.user_id == ^user_id,
        order_by: [desc: s.updated_at, desc: s.status]
      )
    )
  end

  def get_swarm_licenses_by_biotope(biotope_id) do
    Repo.all(
      from(s in SwarmLicense, where: s.biotope_id == ^biotope_id, order_by: [desc: s.updated_at])
    )
  end

  def get_swarm_licenses_by_edge(edge_id) do
    Repo.all(
      from(s in SwarmLicense, where: s.edge_id == ^edge_id, order_by: [desc: s.updated_at])
    )
  end
end
