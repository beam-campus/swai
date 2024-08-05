defmodule Edge.Emitter do
  @moduledoc """
  Edge.Emitter is a GenServer that manages a channel to a scape,
  """
  alias Edge.Client
  alias Scape.Init, as: ScapeInit
  alias Scape.Facts, as: ScapeFacts


  require Logger

  # @attach_scape_v1 "attach_scape:v1"
  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scape_initialized_v1 ScapeFacts.scape_initialized_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()

  def emit_initializing_scape(scape_init),
    do:
    Client.publish(
      scape_init.edge_id,
      @initializing_scape_v1,
      %{scape_init: scape_init}
    )

  def emit_scape_initialized(scape_init),
    do:
    Client.publish(
      scape_init.edge_id,
      @scape_initialized_v1,
      %{scape_init: scape_init}
    )

  def scape_detached(scape_init),
    do:
    Client.publish(
      scape_init.edge_id,
      @scape_detached_v1,
      %{scape_init: scape_init}
    )


end
