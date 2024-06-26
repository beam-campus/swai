defmodule Mating.Payload do
  use Ecto.Schema

  @moduledoc """
  the payload for the life:breed facts and hopes
  """

  alias Mating.Payload, as: MatingPayload

  import Ecto.Changeset
  require Jason.Encoder

  @all_fields [
    :edge_id,
    :scape_id,
    :region_id,
    :mng_farm_id,
    :his_id,
    :her_id,
    :is_success
  ]

  @required_fields [
    :edge_id,
    :scape_id,
    :region_id,
    :mng_farm_id,
    :his_id,
    :her_id,
    :is_success
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:region_id, :string)
    field(:mng_farm_id, :string)
    field(:his_id, :string)
    field(:her_id, :string)
    field(:is_success, :boolean, default: false)
  end

  def from_map(map) do
    case changeset(%MatingPayload{}, map) do
      %{valid?: true} = changeset ->
        Ecto.Changeset.apply_changes(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  def changeset(payload, attrs) do
    payload
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end
end
