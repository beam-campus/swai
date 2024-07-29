defmodule SwaiWeb.Dispatch.Born2DiedHandler do
  @moduledoc """
  The AnimalHandler is used to broadcast messages to all clients
  """

  require Logger

  alias Phoenix.PubSub
  alias Born2Died.Movement
  alias Born2Died.Facts, as: LifeFacts
  alias Born2Died.State, as: LifeState
  alias Born2Died.Movement, as: Movement
  alias Lives.Service, as: Born2DiedsCache

  @initializing_life_v1 LifeFacts.initializing_life_v1()
  @life_initialized_v1 LifeFacts.life_initialized_v1()
  @life_state_changed_v1 LifeFacts.life_state_changed_v1()
  @life_died_v1 LifeFacts.life_died_v1()

  @life_moved_v1 LifeFacts.life_moved_v1()

  def pub_initializing_animal_v1(payload, socket) do
    Logger.info("pub_initializing_animal_v1 #{inspect(payload)}")
    {:ok, animal_init} = LifeState.from_map(payload["life_init"])

    Born2DiedsCache.save(animal_init)

    Phoenix.PubSub.broadcast(
      Swai.PubSub,
      @initializing_life_v1,
      {@initializing_life_v1, animal_init}
    )

    {:noreply, socket}
  end

  def pub_animal_initialized_v1(payload, socket) do
    Logger.info("pub_animal_initialized_v1 #{inspect(payload)}")
    {:ok, animal_init} = LifeState.from_map(payload["life_init"])

    Phoenix.PubSub.broadcast(
      Swai.PubSub,
      @life_initialized_v1,
      {@life_initialized_v1, animal_init}
    )

    {:noreply, socket}
  end

  def pub_life_state_changed_v1(payload, socket) do
    Logger.info("pub_life_state_changed_v1 #{inspect(payload)}")
    {:ok, life_init} = LifeState.from_map(payload["life_init"])
    Lives.Service.save(life_init)

    Phoenix.PubSub.broadcast(
      Swai.PubSub,
      @life_state_changed_v1,
      {@life_state_changed_v1, life_init}
    )

    {:noreply, socket}
  end

  def pub_life_died_v1(payload, socket) do
    Logger.info("pub_life_died_v1 #{inspect(payload)}")
    {:ok, life_init} = LifeState.from_map(payload["life_init"])
    Lives.Service.save(life_init)

    Phoenix.PubSub.broadcast(
      Swai.PubSub,
      @life_died_v1,
      {@life_state_changed_v1, life_init}
    )

    {:noreply, socket}
  end

  def pub_life_moved_v1(payload, socket) do

    # Logger.alert("pub_life_moved_v1 #{inspect(payload)}")

    {:ok, %Movement{} = movement} = Movement.from_map(payload["movement"])

    PubSub.broadcast(
      Swai.PubSub,
      @life_moved_v1,
      {@life_moved_v1, movement}
    )

    {:noreply, socket}
  end
end
