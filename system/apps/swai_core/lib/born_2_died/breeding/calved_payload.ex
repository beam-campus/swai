defmodule Calved.Payload do
  use Ecto.Schema

  @moduledoc """
  the payload for the edge:attached:v1 fact
  """

  alias Schema.Life
  alias Schema.Meta, as: Meta

  @primary_key false
  embedded_schema do

    field(:life_id, :string)
    field(:birth_time, :utc_datetime_usec)
    embeds_one(:offspring, Life)
  end

  def new(life_id, birth_time, offspring),
    do: %__MODULE__{
      life_id: life_id,
      birth_time: birth_time,
      offspring: offspring
    }
end
