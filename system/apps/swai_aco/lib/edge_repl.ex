defmodule EdgeRepl do

  alias Scape.Init, as: ScapeInit
  alias Schema.SwarmLicense, as: License
  alias Schema.SwarmLicense.Status, as: LicenseStatus

  alias Scape.System, as: ScapeSystem

  def start_test_scape() do
    test_scape_init = Scape.Init.test_scape_init()
    case ScapeSystem.start_link(test_scape_init) do
      {:ok, _} -> IO.puts("ScapeSystem started")
      {:error, _} -> IO.puts("ScapeSystem failed to start")
    end
  end


end
