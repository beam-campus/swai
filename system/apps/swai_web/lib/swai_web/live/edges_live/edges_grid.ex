defmodule SwaiWeb.EdgesLive.EdgesGrid do
  use SwaiWeb, :live_component

  alias Edges.Service

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end






end
