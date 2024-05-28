defmodule SwaiWeb.ViewRegionsLive.RegionsGrid do
  use SwaiWeb, :live_component

  @moduledoc """
  The live component for the scapes grid.
  """

  def get_regions_summary(regions) do
    regions
    |> Enum.reduce(%{}, fn region, acc -> Map.update(acc, %{name: region.name, id: region.id, continent: region.continent}, 1, & &1 + 1) end)
    |> Map.to_list()
    |> Enum.sort()
    |> Enum.map(fn {%{id: id, name: name, continent: continent}, count} -> {id, %{name: name, continent: continent, count: count}} end)
  end


  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end


end
