defmodule Schema.SwarmLicense do
  @moduledoc """
  The schema module for the swarm licenses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  defmodule Status do
    @moduledoc """
    The status flags for the swarm licenses.
    """
    require Flags
    def unknown, do: 0

    def license_initialized, do: 1
    def license_configured, do: 2
    def license_active, do: 4
    def license_inactive, do: 8
    def license_paid, do: 16
    def license_blocked, do: 32

    def scape_queued, do: 256
    def scape_started, do: 512
    def scape_paused, do: 1024
    def scape_cancelled, do: 2048
    def scape_completed, do: 4096

    def map,
      do: %{
        unknown() => "unknown",
        license_initialized() => "initialized",
        license_configured() => "configured",
        license_active() => "active",
        license_inactive() => "inactive",
        license_paid() => "paid",
        license_blocked() => "blocked",
        scape_queued() => "queued",
        scape_started() => "started",
        scape_paused() => "paused",
        scape_cancelled() => "cancelled",
        scape_completed() => "completed"
      }

    def style,
      do: %{
        unknown() => "bg-gray-500 text-white",
        license_initialized() => "bg-green-500 text-white",
        license_configured() => "bg-blue-500 text-white",
        license_paid() => "bg-blue-500 text-white",
        license_blocked() => "bg-red-500 text-white",
        scape_queued() => "bg-blue-500 text-white",
        scape_started() => "bg-blue-500 text-white",
        scape_paused() => "bg-orange-500 text-white",
        scape_cancelled() => "bg-red-500 text-white",
        scape_completed() => "bg-blue-500 text-white"
      }

    def to_list(status), do: Flags.to_list(status, map())
    def highest(status), do: Flags.highest(status, map())
    def lowest(status), do: Flags.lowest(status, map())
    def to_string(status), do: Flags.to_string(status, map())
  end

  alias Schema.SwarmLicense, as: SwarmLicense

  alias Schema.SwarmLicense.Status, as: Status

  @all_fields [
    :license_id,
    :status,
    :status_string,
    :user_id,
    :algorithm_id,
    :algorithm_name,
    :algorithm_acronym,
    :biotope_id,
    :biotope_name,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :cost_in_tokens,
    :tokens_used,
    :run_time_sec,
    :available_tokens,
    :tokens_balance
  ]

  @id_fields [
    :license_id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :algorithm_id,
    :algorithm_name,
    :algorithm_acronym
  ]

  @primary_key false
  schema "swarm_licenses" do
    field(:license_id, :binary_id, primary_key: true)

    field(:status, :integer, default: Status.unknown())
    field(:status_string, :string, virtual: true)
    field(:user_id, :binary_id)

    field(:algorithm_id, :binary_id)
    field(:algorithm_name, :string)
    field(:algorithm_acronym, :string)

    field(:biotope_id, :binary_id)
    field(:biotope_name, :string)

    field(:swarm_id, :binary_id, default: UUID.uuid4())

    field(:swarm_name, :string,
      default: MnemonicSlugs.generate_slug(3) |> String.replace("-", "_")
    )

    field(:swarm_size, :integer, default: 100)

    field(:swarm_time_min, :integer, default: 30)

    field(:cost_in_tokens, :integer, default: 3000)

    field(:tokens_used, :integer, default: 0)

    field(:run_time_sec, :integer, default: 0)

    field(:available_tokens, :integer, default: 0)

    field(:tokens_balance, :integer, default: 0)

    timestamps(type: :utc_datetime_usec)
  end

  defp calculate_cost_in_tokens(%Ecto.Changeset{} = changeset) do
    new_training =
      changeset
      |> apply_changes()

    new_cost =
      new_training.swarm_size *
        new_training.swarm_time_min

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

  defp validate_swarm_name(changeset, _opts \\ []) do
    changeset
    |> validate_required([:swarm_name])
    |> validate_length(:swarm_name, min: 3, max: 50)
    |> validate_format(:swarm_name, ~r/^[a-zA-Z0-9_]+$/,
      message: "can only contain letters, numbers, and underscores"
    )
    |> validate_format(:swarm_name, ~r/^\S+$/, message: "cannot be blank")
  end

  def changeset(swarm_license, map) when is_struct(map),
    do: changeset(swarm_license, Map.from_struct(map))

  def changeset(swarm_license, map) when is_map(map),
    do:
      swarm_license
      |> cast(map, @all_fields)
      |> validate_required(@id_fields)
      |> validate_number(:swarm_size, greater_than: 4)
      |> validate_number(:swarm_time_min, greater_than: 1)
      |> validate_number(:available_tokens, greater_than: -1)
      |> calculate_cost_in_tokens()
      |> validate_number(:cost_in_tokens, greater_than: -1)
      |> calculate_status_string()
      |> validate_swarm_name()

  def from_map(%SwarmLicense{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%SwarmLicense{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end

  def new(user_id, biotope_id, biotope_name, algorithm_id, algorithm_name, algorithm_acronym),
    do: %SwarmLicense{
      license_id: UUID.uuid4(),
      user_id: user_id,
      biotope_id: biotope_id,
      biotope_name: biotope_name,
      algorithm_id: algorithm_id,
      algorithm_name: algorithm_name,
      algorithm_acronym: algorithm_acronym
    }
end
