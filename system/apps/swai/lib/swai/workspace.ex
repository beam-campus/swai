defmodule Swai.Workspace do
  @moduledoc """
  The Workspace context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Swai.Repo
  alias Schema.SwarmTraining, as: SwarmTraining

  def exists_swarm_training?(id) do
    query = from(s in SwarmTraining, where: s.id == ^id)
    Repo.exists?(query)
  end

  def list_swarm_trainings do
    Repo.all(SwarmTraining)
  end

  def get_swarm_training!(id), do: Repo.get!(SwarmTraining, id)

  def create_swarm_training(attrs \\ %{}) do
    if not exists_swarm_training?(attrs.id) do
      case %SwarmTraining{}
           |> SwarmTraining.changeset(attrs) do
        %{valid?: true} = changeset ->
          res =
            changeset
            |> Repo.insert()


          res

        changeset ->
          Logger.error("Invalid changeset: #{inspect(changeset)}")
          changeset
      end
    else
      Logger.error("SwarmTraining already exists with id #{attrs.id}")
      {:error, "SwarmTraining already exists with id #{attrs.id}"}
    end
  end

  def update_swarm_training(%SwarmTraining{} = swarm_training, attrs) do
    swarm_training
    |> SwarmTraining.changeset(attrs)
    |> Repo.update()
  end

  def delete_swarm_training(%SwarmTraining{} = swarm_training) do
    Repo.delete(swarm_training)
  end

  def change_swarm_training(%SwarmTraining{} = swarm_training, attrs \\ %{}) do
    SwarmTraining.changeset(swarm_training, attrs)
  end

  def get_swarm_trainings_by_user_id(user_id) do
    Repo.all(
      from(
        s in SwarmTraining,
        where: s.user_id == ^user_id,
        order_by: [desc: s.updated_at, desc: s.status]
      )
    )
  end

  def get_swarm_trainings_by_biotope(biotope_id) do
    Repo.all(
      from(s in SwarmTraining, where: s.biotope_id == ^biotope_id, order_by: [desc: s.updated_at])
    )
  end

  def get_swarm_trainings_by_edge(edge_id) do
    Repo.all(
      from(s in SwarmTraining, where: s.edge_id == ^edge_id, order_by: [desc: s.updated_at])
    )
  end
end
