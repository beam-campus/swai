defmodule SwaiWeb.Channels.Repl do

  alias Edges.Service, as: Edges
  alias SwaiWeb.EdgeChannel, as: EdgeChannel
  alias Scape.Init, as: ScapeInit
  alias Edge.Init, as: EdgeInit

  require Logger


  def try_start_scapes_on_all_edges() do
    Edges.get_all()
    |> Enum.map(&send_message_to_edge_client/1)
  end


  defp send_message_to_edge_client(edge_init) do
    Process.sleep(2_000)
    scape_init = ScapeInit.from_random(edge_init.id)
    res = EdgeChannel.start_scape(edge_init, scape_init)
    Logger.info("Repl.send_message_to_edge_client: #{inspect(res)}")
  end


end
