defmodule SwaiWeb.UserLoginLive do
  use SwaiWeb, :live_view


  alias Edges.Service,
    as: Edges



  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     socket
     |> assign(
       form: form,
       edges: Edges.get_all()
     ), temporary_assigns: [form: form]}
  end

  def render(assigns) do
    ~H"""
    <div class="lt-edit-gradient flex items-center justify-center flex-col">
      <div class="block items-center justify-center text-white font-brand font-normal">
        <div>
          <h1 class="text-2xl" >
            Sign in to your account
          </h1>
        </div>
        <div class="text-xs">
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </div>
      </div>
    </div>

    <div class="mx-auto max-w-sm bg-ltDark">

      <.simple_form
        for={@form}
        id="login_form"
        action={~p"/users/log_in"}
        phx-update="ignore"
        class="text-center text-white font-brand font-normal">
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            required
          />
          <.input
            field={@form[:password]}
            type="password"
            label="Password"
            required
          />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
              Forgot your password?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Signing in..." class="lt-submit-button w-full">
              Sign in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
      </.simple_form>
    </div>
    """
  end
end
