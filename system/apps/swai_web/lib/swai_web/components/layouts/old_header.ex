defmodule SwaiWeb.Layouts.OldHeader do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <header class="fixed top-0 left-0 right-0 flex items-center justify-between pl-1 pr-3 py-1 bg-ltDark z-199">
    <!-- Left side of toolbar -->
    <div class="flex flex-row items-center">
        <a href={~p"/"}>
          <img src="/images/swai-logo-nobg.svg" alt="swai logo" width="200" />
        </a>
        <p class="text-ltRed text-s font-brand mt-2 px-5"><%= assigns[:page_title] %> </p>
        <div class="font-brand text-xs text-white px-5" id="bar-disclaimer">
          <span>
          DISCLAIMER: This site is still WiP!<br/>
          If you want to support our work, please consider <a href="https://www.buymeacoffee.com/beamologist" class="text-ltOrange hover:underline">buying us a coffee</a>
          </span>
        </div>
    </div>

    <!-- Right side of toolbar -->
    <div class="flex items-center flex-row">

     <.live_component
        id="user_box"
        module={SwaiWeb.UserBox}
        current_user={@current_user}
      />
    </div>





      <%!-- <%= if @current_user do %>
      <div class="fixed-component-container" style="position: flex; top: 20px; right: 20px; z-index: 1000;">
        <.live_component
          id={"user_budget_box_#{@current_user.id}"}
          module={SwaiWeb.BudgetBox}
          user={@current_user}
          phx-hook="BudgetBox"
        />
        </div>
              <%!-- <%= if @current_user do %>
        <button
          class="img-down-arrow-user"
          type="button"
          id="user_menu_button"
          phx-click={SwaiWeb.Layouts.App.toggle_dropdown_menu()}
        >
          <img
            src={"https://api.dicebear.com/8.x/bottts/svg?seed=#{@current_user.id}"}
            alt="Profile Image"
            class="w-8 h-8 round-image-padding-user"
          />
        </button>
      <% else %>
        <button
          class="img-down-arrow"
          type="button"
          id="user_menu_button"
          phx-click={SwaiWeb.Layouts.App.toggle_dropdown_menu()}
        >
          <img
            src="/images/user-image.svg"
            alt="Profile Image"
            class="w-8 h-8 round-image-padding"
          />
        </button>
      <% end %> --%>
      <%!-- <.live_component
        id="user_menu"
        module={SwaiWeb.UserMenu}
        current_user={@current_user}
      /> --%>
    </header>

    """
  end

end
