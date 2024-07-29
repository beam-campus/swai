defmodule Schema.SwarmTraining do
  use Ecto.Schema
  import Ecto.Changeset

  defmodule Status do
    require Flags

    def unknown, do: 0
    def initialized, do: 1
    def configured, do: 2
    def running, do: 4
    def paused, do: 8
    def cancelled, do: 16
    def completed, do: 32
    def active, do: 64
    def inactive, do: 128

    def map,
      do: %{
        unknown() => "unknown",
        initialized() => "initialized",
        configured() => "configured",
        running() => "running",
        paused() => "paused",
        cancelled() => "cancelled",
        completed() => "completed",
        active() => "active",
        inactive() => "inactive"
      }

    def to_list(status),
      do: Flags.to_list(status, map())

    def highest(status),
      do: Flags.highest(status, map())

    def lowest(status),
      do: Flags.lowest(status, map())

    def to_string(status),
      do: Flags.to_string(status, map())
  end

  alias Schema.SwarmTraining,
    as: SwarmTraining

  alias Schema.SwarmTraining.Status,
    as: Status

  @all_fields [
    :id,
    :status,
    :swarm_id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :generation_epoch_in_minutes,
    :select_best_count,
    :cost_in_tokens,
    :tokens_used,
    :total_run_time_in_seconds,
    :budget_in_tokens,
    :scape_id,
    :swarm_name
  ]

  @id_fields [
    :id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :swarm_id,
    :swarm_name
  ]

  @config_fields [
    :status,
    :scape_id,
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :generation_epoch_in_minutes,
    :select_best_count,
    :cost_in_tokens
  ]

  @runtime_fields [
    :tokens_used,
    :total_run_time_in_seconds,
    :budget_in_tokens
  ]

  @primary_key false
  @foreign_key_type :binary_id
  schema "swarm_trainings" do
    field(:id, :binary_id, primary_key: true)
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:biotope_name, :string)
    field(:status, :integer, default: Status.unknown())

    field(:scape_id, :string)

    field(:swarm_id, :binary_id, default: UUID.uuid4())
    field(:swarm_name, :string, default: MnemonicSlugs.generate_slug(3))

    field(:swarm_size, :integer, default: 100)
    field(:nbr_of_generations, :integer, default: 100)
    field(:drone_depth, :integer, default: 5)
    ## SWARMING TIME
    field(:generation_epoch_in_minutes, :integer, default: 30)
    field(:select_best_count, :integer, default: 3)
    field(:cost_in_tokens, :integer, default: 0)

    field(:tokens_used, :integer, default: 0)
    field(:total_run_time_in_seconds, :integer, default: 0)
    field(:budget_in_tokens, :integer, default: 0)

    field(:status_string, :string, virtual: true)

    timestamps(type: :utc_datetime_usec)
  end

  defp calculate_cost_in_tokens(%Ecto.Changeset{} = changeset) do
    new_training =
      changeset
      |> apply_changes()

    new_cost =
      new_training.swarm_size *
        new_training.generation_epoch_in_minutes

    new_changeset =
      changeset
      |> put_change(:cost_in_tokens, new_cost)

    new_changeset
  end

  defp calculate_status_string(%Ecto.Changeset{} = changeset) do
    new_training =
      changeset
      |> apply_changes()

    new_status_string =
      Status.to_string(new_training.status)

    new_changeset =
      changeset
      |> put_change(:status_string, new_status_string)

    new_changeset
  end

  def changeset(swarm_training, map),
    do:
      swarm_training
      |> cast(map, @all_fields)
      |> validate_required(@id_fields)
      |> validate_number(:swarm_size, greater_than: 4)
      |> validate_number(:nbr_of_generations, greater_than: 4)
      |> validate_number(:drone_depth, greater_than: 2)
      |> validate_number(:generation_epoch_in_minutes, greater_than: 1)
      |> validate_number(:select_best_count, greater_than: 1)
      |> calculate_cost_in_tokens()
      |> validate_number(:cost_in_tokens, greater_than: -1)
      |> calculate_status_string()
      |> validate_swarm_name()

      defp validate_swarm_name(changeset, opts \\ []) do
        changeset
        |> validate_required([:swarm_name])
        |> validate_length(:swarm_name, min: 3, max: 30)
        |> validate_format(:swarm_name, ~r/^[a-zA-Z0-9_]+$/,
          message: "can only contain letters, numbers, and underscores"
        )
        |> validate_format(:swarm_name, ~r/^\S+$/,
          message: "cannot be blank"
        )
      end

  def from_map(%SwarmTraining{} = seed, %{} = map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end

  def new(user_id, biotope_id, biotope_name),
    do: %SwarmTraining{
      user_id: user_id,
      biotope_id: biotope_id,
      biotope_name: biotope_name
    }
end
