defmodule SwaiWeb.UserBox do
  use SwaiWeb, :live_component

  alias Swai.Accounts, as: Accounts
  alias Schema.User, as: User

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-center" id="user_box_wrapper">
      <div class="flex flex-row items-center" id="user_box" style="min-width: fit-content; flex-shrink: 0;">
        <div class="flex-grow">
          <.live_component
            module={SwaiWeb.BudgetBox}
            id="budget_box"
            current_user={@current_user}
          />
        </div>
        <div style="flex-shrink: 0;">
        <.live_component
          module={SwaiWeb.UserMenu}
          id="user_menu"
          current_user={@current_user}
        />
        </div>
      </div>
    </div>
    """
  end


  def render2(assigns) do
    ~H"""
    <div class="flex flex-row items-center" id="user_box">
      <.live_component
        module={SwaiWeb.BudgetBox}
        id="budget_box"
        current_user={@current_user}
      />
      <.live_component
        module={SwaiWeb.UserMenu}
        id="user_menu"
        current_user={@current_user}
      />
    </div>
    """
  end

end
