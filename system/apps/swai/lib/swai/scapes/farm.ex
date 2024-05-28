defmodule Service.Scapes.Farm do
  use Ecto.Schema

  @moduledoc """
  Service.Scapes.Farm contains the Ecto schema for the Farm.
  """

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:description, :string)
    field(:latitude, :float)
    field(:longitude, :float)
    embeds_many(:sourced_by, Swai.Stations.Station)
    embeds_many(:animals, Service.Scapes.Animal)
  end



end
