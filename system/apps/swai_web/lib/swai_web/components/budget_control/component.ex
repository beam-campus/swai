defmodule SwaiWeb.BudgetBox do
  use SwaiWeb, :live_component

  alias Swai.Accounts, as: Accounts
  alias Schema.User, as: User

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between bg-white shadow-md rounded-lg mr-2">
      <span class="text-xs font-regular text-gray-700 pl-2" id={"budget_info_#{@user.id}"}>
        <%= @user.budget %> <span> 👾 </span>
        <%!-- <%= if @user.budget <= 0 do %> --%>
        <.link
          href={"/drone_orders/#{@user.id}"}
          class="bg-red-500 hover:bg-red-800 text-white font-regular py-1 px-3 text-xs rounded-lg transition duration-300 ease-in-out"
          role="button"
          method="get"
          id="button_order_drones"
        >
          Populate
        </.link>

      <%!-- <% end %> --%>

        </span>
    </div>
    """
  end
end
