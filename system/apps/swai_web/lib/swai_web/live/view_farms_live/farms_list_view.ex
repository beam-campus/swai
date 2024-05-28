defmodule SwaiWeb.ViewFarmsLive.FarmsListView do
  use SwaiWeb, :live_component

  @moduledoc """
  The live component for the scapes grid.
  """

  def get_farms_summary(farms) do
    farms
    |> Enum.reduce(
      %{},
      fn farm_init, acc ->
        Map.update(
          acc,
          %{
            country: farm_init.country,
            name: farm_init.farm.name,
            id: farm_init.id
          },
          1,
          &(&1 + 1)
        )
      end
    )
    |> Map.to_list()
    |> Enum.sort()
    |> Enum.map(fn {%{id: id, name: name, country: country}, count} ->
      {id, %{country: country, name: name, count: count}}
    end)
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
