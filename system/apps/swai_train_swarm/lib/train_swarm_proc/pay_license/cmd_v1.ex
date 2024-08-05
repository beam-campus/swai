defmodule TrainSwarmProc.PayLicense.CmdV1 do
  @moduledoc """
  PayLicense command schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias TrainSwarmProc.PayLicense.CmdV1, as: PayLicense
  alias TrainSwarmProc.PayLicense.PayloadV1, as: Payment

  @all_fields [:agg_id, :payload]
  @required_fields [:agg_id, :payload]

  @primary_key false
  embedded_schema do
    field(:agg_id, :binary_id)
    embeds_one(:payload, Payment)
  end

  def changeset(%PayLicense{} = seed, params \\ %{}) do
    seed
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def from_map(map) do
    case changeset(%PayLicense{}, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
