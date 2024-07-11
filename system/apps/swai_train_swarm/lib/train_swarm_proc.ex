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

  def change_license_request(%LicenseRequest{} = root, user, biotope) do
    root
    |> LicenseRequest.changeset_from_user_and_biotope(user, biotope)
  end


end
