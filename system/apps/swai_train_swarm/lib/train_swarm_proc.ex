defmodule TrainSwarmProc do
  @moduledoc """
  Documentation for `TrainSwarm`.
  """

  alias TrainSwarmProc.Initialize.Cmd, as: LicenseRequest

  @doc """
  Hello world.

  ## Examples

      iex> TrainSwarm.hello()
      :world

  """

  def change_license_request(%LicenseRequest{} = root, %{} = map) do
    root
    |> LicenseRequest.changeset(map)
  end


end
