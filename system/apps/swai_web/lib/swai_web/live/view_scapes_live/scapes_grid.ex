defmodule SwaiWeb.ViewScapesLive.ScapesGrid do
  use SwaiWeb, :live_component

  @moduledoc """
  The live component for the scapes grid.
  """

  # def get_scapes_summary() do
  #   :scapes_cache
  #   |> Cachex.stream!()
  #   |> Stream.map(fn {:entry, _, _, _, scape} -> scape end)
  #   |> Enum.reduce(%{}, fn scape, acc ->
  #     Map.update(acc, %{name: scape.name, id: scape.id}, 1, &(&1 + 1))
  #   end)
  #   |> Map.to_list()
  #   |> Enum.sort()
  #   |> Enum.map(fn {%{id: id, name: name}, count} -> {id, %{name: name, count: count}} end)
  # end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="px-4 py-1 mx-5 text-white"
      id={"inner-" <> @id}
    >
    <div>
    <div class="flex flex-col">
      <%= for scape <- @scapes do %>
        <.live_component
          module={SwaiWeb.ViewScapesLive.ScapeCard}
          id={"#{@id}_scape_card_#{scape.id}"}
          scape={scape}
        />
      <% end %>
    </div>
    </div>
    </div>

    """
  end
end
