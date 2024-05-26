defmodule Field.Facts do

  @moduledoc """
  The Facts module is used to broadcast messages to all clients
  """

  def initializing_field_v1,
    do: "initializing_field_v1"

  def field_initialized_v1,
    do: "field_initialized_v1"

  def fields_cache_updated_v1,
    do: "fields_cache_updated_v1"


end
