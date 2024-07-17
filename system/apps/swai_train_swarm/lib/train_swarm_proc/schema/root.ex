defmodule TrainSwarmProc.Schema.Root do
  @moduledoc """
  Documentation for `Root`.
  """
  use Ecto.Schema


  alias TrainSwarmProc.Initialize.Payload, as: LicenseRequest
  alias TrainSwarmProc.Schema.Root, as: Root
  import Ecto.Changeset

  @all_fields [
    :id,
    :status,
    :license_request
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :string)
    field(:status, :integer)
    embeds_one(:license_request, LicenseRequest)
  end






end
