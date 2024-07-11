defmodule SwaiWeb.InitializeSwarmLive.Index do
  use SwaiWeb, :live_view

  alias Schema.SwarmLicense, as: SwarmLicense

  alias Swai.Biotopes, as: Biotopes
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.Id, as: Id

  require Logger

  @prefix "swarm_license"

  @impl true
  def mount(unsigned_params, _session, socket) do
    biotope_id = unsigned_params["biotope_id"]

    case connected?(socket) do
      true ->
        {
          :ok,
          socket
          |> assign(
            now: DateTime.utc_now(),
            page_title: "Request to Swarm"
          )
          |> apply_action(biotope_id)
        }

      false ->
        {:ok,
         socket
         |> assign(
           now: DateTime.utc_now(),
           page_title: ""
         )
         |> apply_action(biotope_id)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
    id="initialize-swarm-view"
    class="flex flex-col my-2">
      <.live_component
        id={"init-swarm-specs-#{@swarm_license.id}"}
        module={SwaiWeb.InitializeSwarmLive.RequestToSwarmSection}
        swarm_license={@swarm_license}
        swarm_specs={@swarm_specs}
        biotope={@biotope}
        current_user={@current_user}
      />
    </div>
    """
  end

  @impl true
  def handle_params(unsigned_params, _uri, socket) do
    biotope_id = unsigned_params["biotope_id"]

    case biotope_id do
      nil ->
        {:noreply, socket}

      biotope_id ->
        {:noreply,
         socket
         |> apply_action(biotope_id)}
    end
  end

  defp apply_action(socket, biotope_id) do
    biotope = Biotopes.get_biotope!(biotope_id)
    user = socket.assigns.current_user
    valid_until = DateTime.utc_now() |> DateTime.add(1 * 7 * 24, :hour)

    case SwarmLicense.from_map(%{
           id: Id.new(@prefix) |> Id.as_string(),
           biotope_id: biotope.id,
           user_id: user.id,
           valid_until: valid_until,
           valid_from: DateTime.utc_now(),
           license_type: 1
         }) do
      {:error, changeset} ->
        Logger.error("Error: #{inspect(changeset)}")
        socket

      {:ok, new_license} ->
        swarm_specs =
          SwarmSpec.empty()
          |> SwarmSpecs.with_biotope(biotope)
          |> SwarmSpecs.with_user(user)

        socket
        |> assign(
          biotope: biotope,
          swarm_license: new_license,
          swarm_specs: swarm_specs
        )
    end
  end
end
