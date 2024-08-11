defmodule SwaiWeb.ScapeQueueSup do
  @moduledoc """
  The ScapeQueueSup is used to broadcast messages to all clients
  """
  use Supervisor
  alias SwaiWeb.ScapeQueue, as: ScapeQueue
  require Logger

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def start_queue(biotope_id) do
    Supervisor.start_child(
      __MODULE__,
      {SwaiWeb.ScapeQueue, biotope_id}
    )
  end

  def init(:ok) do

    children = [
      ScapeQueue
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end


end
