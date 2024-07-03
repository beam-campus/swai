defmodule SwaiWeb.InitializeSwarmLive.ModelCard do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={"section-card inactive-biotope"}>
      <div class="section-card-header">
        <img class="h-24 w-full object-cover opacity-80"
        src={"#{@biotope.image_url}"} alt={"#{@biotope.id}"}
        >
      </div>
      <div class="section-card-body">
        <p class="text-sm font-medium text-lt-edit-gradient uppercase">
          <%= @biotope.theme %>
        </p>
        <a href="#{Routes.biotope_path(@socket, :show, @biotope)}"
        class="block mt-2 text-xl font-semibold text-lt-section-header">
          <%= @biotope.name %>
        </a>
        <p class="mt-3 text-base text-white">
          <%= @biotope.description %>
        </p>
        <p class="mt-3 text-base text-white">
          <%= @biotope.objective %>
        </p>
        <p class="mt-3 text-base text-white">
          <%= @biotope.challenges %>
        </p>



      </div>
    </div>
    """
  end

  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"



end
