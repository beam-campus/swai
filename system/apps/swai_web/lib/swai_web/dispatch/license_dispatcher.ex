defmodule SwaiWeb.LicenseDispatcher do
  @moduledoc false

  alias Licenses.Service, as: Licenses
  alias TrainSwarmProc.CommandedApp, as: ProcApp
  alias TrainSwarmProc.PauseLicense.CmdV1, as: PauseLicense

  require Logger

  defp do_detach_license(%{license_id: agg_id} = license) do
    pause_license_cmd = %PauseLicense{
      agg_id: agg_id,
      version: 1,
      payload: license
    }
    ProcApp.dispatch(pause_license_cmd)
  end

  def detach_edge(edge_id) do
    case Licenses.get_for_edge(edge_id) do
      [] ->
        Logger.warning("detach_licenses: no licenses found to pause for edge_id: #{edge_id}")
        []

      licenses ->
        Enum.each(licenses, fn license ->
          do_detach_license(license)
        end)
        licenses
    end
  end

end
