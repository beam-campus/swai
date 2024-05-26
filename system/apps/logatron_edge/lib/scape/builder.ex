defmodule Scape.Builder do
  use GenServer

  @moduledoc """
  LogatronEdge.Scape.Worker is a GenServer that manages the state of a Scape.
  """
  require Logger


  alias Apis.Countries, as: Countries
  alias Scape.Init, as: ScapeInit


  ######### API #############
  def get_state(scape_id),
    do:
      GenServer.call(
        via(scape_id),
        {:get_state}
      )

  ############## INTERNALS ############
  defp start_regions(%ScapeInit{} = scape_init) do
    selection =
      String.split(scape_init.select_from, ",")
      |> Enum.map(&String.trim/1)

    Countries.countries_of_regions(selection, scape_init.min_area, scape_init.min_people)
    |> Enum.take_random(scape_init.nbr_of_countries)
    |> Enum.each(fn country ->
      region_id =
        country.name
        |> String.replace(" ", "_")
        |> String.downcase()

      region_init =
        Region.Init.random(
          scape_init.edge_id,
          scape_init.id,
          region_id,
          country.name,
          country.region,
          country.subregion
        )

      Scape.Regions.start_region(region_init)
    end)

    scape_init
  end

  ########## CALLBACKS ################
  @impl GenServer
  def init(scape_init),
    do: {:ok, start_regions(scape_init)}

  @impl GenServer
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  ############## PLUMBING ############
  def to_name(key) when is_bitstring(key),
    do: "scape.builder.#{key}"

  def via(key),
    do: Edge.Registry.via_tuple({:builder, to_name(key)})

  def child_spec(%{id: scape_id} = scape_init),
    do: %{
      id: to_name(scape_id),
      start: {__MODULE__, :start_link, [scape_init]},
      type: :worker,
      restart: :transient
    }

  def start_link(%{id: scape_id} = scape_init),
    do:
      GenServer.start_link(
        __MODULE__,
        scape_init,
        name: via(scape_id)
      )
end
