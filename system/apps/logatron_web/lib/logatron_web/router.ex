defmodule LogatronWeb.Router do
  use LogatronWeb, :router

  import LogatronWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LogatronWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LogatronWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:logatron_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LogatronWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", LogatronWeb do
    pipe_through [:browser]
    live_session :edges_info,
      on_mount: [
        {LogatronWeb.EdgesInfo, :mount_edges_count},
        {LogatronWeb.UserAuth, :mount_current_user}
      ] do
      live "/edges_live", EdgesLive.Index, :index
    end
  end

  ## Authentication routes

  scope "/", LogatronWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {LogatronWeb.UserAuth, :redirect_if_user_is_authenticated},
        {LogatronWeb.EdgesInfo, :mount_edges_count}
      ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LogatronWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {LogatronWeb.UserAuth, :ensure_authenticated},
        {LogatronWeb.EdgesInfo, :mount_edges_count}
      ] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/world/", BrowseWorldLive, :show
      live "/stations", StationLive.Index, :index
      live "/devices", DeviceLive.Index, :index

      live "/view_scapes", ViewScapesLive.Index, :index
      live "/view_regions", ViewRegionsLive.Index, :index
      live "/view_farms", ViewFarmsLive.Index, :index
      live "/view_lives", ViewBorn2DiedsLive.Index, :index
      live "/view_fields", ViewFieldsLive.Index, :index
    end
  end

  scope "/", LogatronWeb do
    pipe_through [:browser]
    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [
        {LogatronWeb.UserAuth, :mount_current_user},
        {LogatronWeb.EdgesInfo, :mount_edges_count}
      ] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
      live "/about", AboutLive, :show

      live "/stations/new", StationLive.Index, :new
      live "/stations/edit/:id", StationLive.Index, :edit

      live "/devices/:id/edit", DeviceLive.Index, :edit
      live "/devices/:id/show/edit", DeviceLive.Show, :edit
      live "/devices/new", DeviceLive.Index, :new

      live "/born_2_dieds/new", AnimalLive.Index, :new
      live "/born_2_dieds/:id/edit", AnimalLive.Index, :edit

      live "/born_2_dieds/:id", AnimalLive.Show, :show
      live "/born_2_dieds/:id/show/edit", AnimalLive.Show, :edit
    end
  end
end
