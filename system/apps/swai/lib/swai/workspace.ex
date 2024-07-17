defmodule Swai.Workspace do
  @moduledoc """
  The Workspace context.
  """

  import Ecto.Query, warn: false
  alias Swai.Repo

  alias Swai.Workspace.SwarmTraining

  @doc """
  Returns the list of swarm_trainings.

  ## Examples

      iex> list_swarm_trainings()
      [%SwarmTraining{}, ...]

  """
  def list_swarm_trainings do
    Repo.all(SwarmTraining)
  end

  @doc """
  Gets a single swarm_training.

  Raises `Ecto.NoResultsError` if the Swarm training does not exist.

  ## Examples

      iex> get_swarm_training!(123)
      %SwarmTraining{}

      iex> get_swarm_training!(456)
      ** (Ecto.NoResultsError)

  """
  def get_swarm_training!(id), do: Repo.get!(SwarmTraining, id)

  @doc """
  Creates a swarm_training.

  ## Examples

      iex> create_swarm_training(%{field: value})
      {:ok, %SwarmTraining{}}

      iex> create_swarm_training(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_swarm_training(attrs \\ %{}) do
    %SwarmTraining{}
    |> SwarmTraining.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a swarm_training.

  ## Examples

      iex> update_swarm_training(swarm_training, %{field: new_value})
      {:ok, %SwarmTraining{}}

      iex> update_swarm_training(swarm_training, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_swarm_training(%SwarmTraining{} = swarm_training, attrs) do
    swarm_training
    |> SwarmTraining.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a swarm_training.

  ## Examples

      iex> delete_swarm_training(swarm_training)
      {:ok, %SwarmTraining{}}

      iex> delete_swarm_training(swarm_training)
      {:error, %Ecto.Changeset{}}

  """
  def delete_swarm_training(%SwarmTraining{} = swarm_training) do
    Repo.delete(swarm_training)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking swarm_training changes.

  ## Examples

      iex> change_swarm_training(swarm_training)
      %Ecto.Changeset{data: %SwarmTraining{}}

  """
  def change_swarm_training(%SwarmTraining{} = swarm_training, attrs \\ %{}) do
    SwarmTraining.changeset(swarm_training, attrs)
  end
end
