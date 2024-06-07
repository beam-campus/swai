defmodule SwaiWeb.MyHiveLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  A live view for the MyHive page.
  """

  alias Swai.MyHive.Service, as: MyHiveService

  require Logger



  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        Logger.info("Connected")
          {
          :ok,
          socket
          |> assign(
            my_hive: MyHiveService.get_all()
          )
        }

      false ->
        Logger.info("Not connected")

        {:ok,
         socket
         |> assign(
           my_hive: []
         )}
    end
  end


  @impl true
  def handle_info(_msg, socket),
    do: {
      :noreply,
      socket
    }

end
