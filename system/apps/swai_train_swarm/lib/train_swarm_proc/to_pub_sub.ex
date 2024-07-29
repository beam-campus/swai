defmodule TrainSwarmProc.ToPubSub.V1 do
  use Commanded.Event.Handler,
    name: "TrainSwarmProc.ToPubSub.V1",
    application: TrainSwarmProc.CommandedApp,
    start_from: :origin

  alias Commanded.PubSub

  alias TrainSwarmProc.Initialize.Evt.V1, as: InitializedV1
    alias TrainSwarmProc.Configure.Evt.V1, as: ConfiguredV1
  alias TrainSwarmProc.Facts, as: Facts
  alias Phoenix.PubSub, as: PubSub

  require Logger


  @initialized_v1 Facts.initialized()
  @configured_v1 Facts.configured()

  ###################### INITIALIZED #######################
  @impl true
  def handle(%InitializedV1{} = evt, metadata) do
    Logger.alert("INITIALIZING SWARM TRAINING with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast(@initialized_v1, {@initialized_v1, evt, metadata})

    :ok
  end

  ####################### CONFIGURED #######################
  @impl true
  def handle(%ConfiguredV1{} = evt, metadata) do
    Logger.alert("CONFIGURING SWARM TRAINING with event #{inspect(evt)}")

    Swai.PubSub
    |> PubSub.broadcast!(@configured_v1, {@configured_v1, evt, metadata})

    :ok
  end

  @impl true
  def handle(msg, _metadata) do
    Logger.warning("Unhandled event #{inspect(msg)}")
    {:error, "Unhandled event #{inspect(msg)}"}
  end
end
