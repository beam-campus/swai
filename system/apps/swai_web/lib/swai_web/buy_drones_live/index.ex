defmodule SwaiWeb.BuyDronesLive.Index do
  use SwaiWeb, :live_view

  alias Swai.Accounts, as: Accounts
  alias Schema.User, as: User


  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(page_title: "Get Drones")}
      false ->
        {:ok,
         socket
         |> assign(page_title: "Get Drones")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
     <div class="modal-content">
        <p>Your budget: <%= @current_user.budget %></p>
        <button phx-click="toggle-buy-drones">Close</button>
      </div>
    """
  end

end
