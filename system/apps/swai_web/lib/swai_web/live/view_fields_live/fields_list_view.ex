defmodule SwaiWeb.ViewFieldsLive.FieldsListView do
  use SwaiWeb, :live_component

  @moduledoc """
  The live component for the fields list view.
  """

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-1 mx-5 text-white">
    <div>
    <div class="flex flex-col">
      <%= for field <- @fields do %>
        <p class="text-2xl text-white"><%= " Field No: #{field.depth}  ( #{field.cols}, #{field.rows}  )" %></p>
        <.live_component
          module={SwaiWeb.ViewFieldsLive.FieldCard}
          id={@current_user.id <> "field-card" <> "#{field.depth}"}
          field={field}
          current_user={@current_user}
          mng_farm_id={@mng_farm_id}
          cell_states={@cell_states}
          tick={@tick}
          />
      <% end %>
    </div>
    </div>
    </div>

    """
  end
end
