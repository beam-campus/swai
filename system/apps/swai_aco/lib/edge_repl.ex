defmodule EdgeRepl do
  alias Scape.Init, as: ScapeInit
  alias Schema.SwarmLicense, as: License
  alias Schema.SwarmLicense.Status, as: LicenseStatus

  alias Scape.System, as: ScapeSystem
  alias Edge.Init, as: EdgeInit
  alias Edge.System, as: EdgeSystem

  def start_test_scape() do
    test_scape_init = Scape.Init.test_scape_init()

    case ScapeSystem.start_link(test_scape_init) do
      {:ok, _} -> IO.puts("ScapeSystem started")
      {:error, _} -> IO.puts("ScapeSystem failed to start")
    end
  end

  def start_test_edge() do
    test_edge_init = %EdgeInit{
      edge_id: "test_edge",
      scapes_cap: 1,
      hives_cap: 1
    }

    case EdgeSystem.start(test_edge_init) do
      {:ok, _} -> IO.puts("EdgeSystem started")
      {:error, _} -> IO.puts("EdgeSystem failed to start")
    end
  end
end
