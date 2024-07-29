defmodule TrainSwarmProc.ToPostgresDoc.V1 do
  use Commanded.Event.Handler,
    name: "TrainSwarmProc.ToPostgresDoc.V1",
    application: TrainSwarmProc.CommandedApp,
    start_from: :origin

  alias TrainSwarmProc.Initialize.Evt.V1, as: Initialized
  alias Schema.SwarmTraining, as: SwarmTraining
  alias Swai.Workspace, as: MyWorkspace
  alias TrainSwarmProc.Configure.Evt.V1, as: Configured
  alias Schema.SwarmTraining.Status, as: Status


  require Logger

  @initialized Status.initialized()
  @configured Status.configured()

  ####################### INITIALIZED #######################
  @impl true
  def handle(
        %Initialized{
          agg_id: agg_id,
          payload: payload
        } = evt,
        _metadata
      ) do
    payload =
      payload
      |> Map.put(:id, agg_id)
      |> Map.put(:status, @initialized)

    MyWorkspace.create_swarm_training(payload)


    :ok
  end

  ####################### CONFIGURED #######################
  @impl true
  def handle(
        %Configured{
          agg_id: agg_id,
          payload: payload
        } = evt,
        _metadata
      ) do
    Logger.alert("Handling Configured event => #{inspect(evt)}")
    st = MyWorkspace.get_swarm_training!(agg_id)

    case SwarmTraining.from_map(st, payload) do
      {:ok, st} ->
        new_st = %{st | status: @configured}

        new_st
        |> MyWorkspace.update_swarm_training(payload)

        :ok

      {:error, changeset} ->
        Logger.error("Invalid license request params #{inspect(changeset)}")
        {:error, "Invalid license request params #{inspect(changeset)}"}
    end
  end

  # @impl true
  # def handle(_, _) do
  #   :ok
  # end
end
