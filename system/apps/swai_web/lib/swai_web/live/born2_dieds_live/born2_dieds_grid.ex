defmodule SwaiWeb.Born2DiedsLive.Born2DiedsGrid do
  use SwaiWeb, :live_component

  # def get_born2dieds_summary(born2dieds) do
  #   born2dieds
  #   |> Enum.reduce(%{}, fn born2died, acc ->
  #     Map.update(acc, born2died.animal_id, 1, &(&1 + 1))
  #   end)
  # end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
