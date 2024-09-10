defmodule SwaiWeb.LicenseQueue do
  @moduledoc """
  The LicenseQueue is used to broadcast messages to all clients
  """
  use GenServer

  require Logger

  # alias SwaiWeb.EdgeChannel
  # alias Edges.Service, as: Edges
  # alias Licenses.Service, as: Licenses
  # alias Hives.Service, as: Hives

  alias Hive.Init, as: HiveInit
  alias Schema.SwarmLicense, as: License
  alias Hive.Facts, as: HiveFacts
  alias Licenses.Service, as: Licenses
  alias Phoenix.PubSub, as: PubSub
  alias SwaiWeb.EdgeChannel, as: EdgeChannel

  require Logger
  require Colors

  @hive_facts HiveFacts.hive_facts()
  @hive_vacated_v1 HiveFacts.hive_vacated_v1()
  @hive_occupied_v1 HiveFacts.hive_occupied_v1()

  defp try_present_license(
         %HiveInit{} = hive_init,
         %License{biotope_id: biotope_id} = license
       ) do
  end

  def start(init_args) do
    case start_link(init_args) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, reason} -> {:error, reason}
    end
  end

  ################# INIT ##########################
  @impl true
  def init(_init_args \\ []) do
    Logger.debug("LicenseQueue is up: #{Colors.server_theme(self())}")

    Swai.PubSub
    |> PubSub.subscribe(@hive_facts)

    {:ok, []}
  end

  ############## HIVE VACATED LISTENER ###########
  @impl true
  def handle_info(
        {
          @hive_vacated_v1,
          %HiveInit{
            biotope_id: biotope_id
          } = hive_init
        },
        state
      ) do
    case Licenses.get_candidates(biotope_id) do
      [] ->
        Logger.info("No candidate licenses for biotope #{biotope_id}")

      candidates ->
        Logger.info("Candidates for biotope #{biotope_id} => #{inspect(candidates)}")

        license =
          candidates
          |> Enum.random()

        Licenses.set_license_presented(license)

        EdgeChannel.present_license(license, hive_init)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  #################### PLUMBING ###################
  def start_link(init_args) do
    GenServer.start_link(
      __MODULE__,
      init_args,
      name: __MODULE__
    )
  end

  def child_spec(init_args),
    do: %{
      id: __MODULE__,
      start: {
        __MODULE__,
        :start,
        [init_args]
      },
      type: :worker
    }

  def via(key),
    do: Swai.Registry.via_tuple({:scape_queue, to_name(key)})

  def via_sup(key),
    do: Swai.Registry.via_tuple({:scape_queue_sup, to_name(key)})

  def to_name(key) when is_bitstring(key),
    do: "license.queue.#{key}"
end
