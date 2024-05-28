defmodule SwaiWeb.Dispatch.ScapeHandler do
  @moduledoc """
  The ScapeHandler is used to broadcast messages to all clients
  """

  alias Scape.Facts, as: ScapeFacts
  alias Scape.Init, as: ScapeInit

  require Logger

  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scape_initialized_v1 ScapeFacts.scape_initialized_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()


  def pub_initializing_scape_v1(scape_init_env, socket) do
    {:ok, scape_init} = ScapeInit.from_map(scape_init_env["scape_init"])

    Phoenix.PubSub.broadcast(
      Swai.PubSub,
      @initializing_scape_v1,
      {@initializing_scape_v1, scape_init}
    )

    {:noreply, socket}
  end

  def pub_scape_initialized_v1(scape_init_env, socket) do
    {:ok, scape_init} = ScapeInit.from_map(scape_init_env["scape_init"])

    Phoenix.PubSub.broadcast(
      Swai.PubSub,
      @scape_initialized_v1,
      {@scape_initialized_v1, scape_init}
    )

    {:noreply, socket}
  end


  def pub_scape_detached_v1(scape_init_env, socket) do
    {:ok, scape_init} = ScapeInit.from_map(scape_init_env["scape_init"])


    Phoenix.PubSub.broadcast(
      Swai.PubSub,
      @scape_detached_v1,
      {@scape_detached_v1, scape_init}
    )

    {:noreply, socket}
  end


end
