defmodule Edge.Emitter do
  @moduledoc """
  Edge.Emitter is a GenServer that manages a channel to a scape,
  """
  alias Edge.Client, as: Client
  alias Scape.Facts, as: ScapeFacts
  alias Scape.Init, as: ScapeInit

  require Logger

  # @attach_scape_v1 "attach_scape:v1"
  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()
  @scape_started_v1 ScapeFacts.scape_started_v1()
  @scape_initialized_v1 ScapeFacts.scape_initialized_v1()

  def emit_initializing_scape(edge_id, %ScapeInit{} = scape_init),
    do:
      Client.publish(
        edge_id,
        @initializing_scape_v1,
        %{scape_init: scape_init}
      )

  def emit_scape_initialized(edge_id, %ScapeInit{} = scape_init),
    do:
      Client.publish(
        edge_id,
        @scape_initialized_v1,
        %{scape_init: scape_init}
      )

  def emit_scape_started(edge_id, %ScapeInit{} = scape_init),
    do:
      Client.publish(
        edge_id,
        @scape_started_v1,
        %{scape_init: scape_init}
      )

end
