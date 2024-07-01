defmodule SwaiWeb.TrainingGroundsLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the training grounds index page.
  """

  alias Edges.Service, as: Edges
  alias Swai.Biotopes, as: Biotopes

  @impl true
  def mount(_params, _session, socket) do
    # current_user = socket.assigns.current_user
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(
           edges: Edges.get_all(),
           biotopes: Biotopes.list_biotopes(),
           now: DateTime.utc_now()
         )}

      false ->
        {:ok,
         socket
         |> assign(
           edges: Edges.get_all(),
           biotopes: Biotopes.list_biotopes(),
           now: DateTime.utc_now()
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div  id="training-grounds-view"  class="flex flex-col">
    <.live_component
        id="training-grounds-list-view"
        module={SwaiWeb.TrainingGroundsLive.TrainingGroundsListView}
        edges={@edges}
        training_grounds={@biotopes}
        now={@now}
    />
    </div>
    """
  end
end
