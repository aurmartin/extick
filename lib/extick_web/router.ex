defmodule ExtickWeb.Router do
  use ExtickWeb, :router

  import ExtickWeb.UserAuth
  import ExtickWeb.Org

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExtickWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExtickWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExtickWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:extick, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ExtickWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ExtickWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ExtickWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ExtickWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/orgs", OrgLive.Index, :index
      live "/orgs/new", OrgLive.Index, :new
      live "/orgs/:id/edit", OrgLive.Index, :edit
    end

    get "/orgs/:id/select", OrgController, :select
  end

  scope "/", ExtickWeb do
    pipe_through [:browser, :require_authenticated_user, :require_current_org]

    live_session :require_current_org,
      on_mount: [{ExtickWeb.UserAuth, :ensure_authenticated}, {ExtickWeb.Org, :require_current_org}] do

      live "/projects", ProjectLive.Index, :index
      live "/projects/new", ProjectLive.New
      live "/projects/:id/edit", ProjectLive.Index, :edit

      live "/projects/:id", ProjectLive.Show, :show
      live "/projects/:id/current_iteration", ProjectLive.ShowCurrentIteration, :show

      live "/projects/:id/current_iteration/new_ticket",
           ProjectLive.ShowCurrentIteration,
           :new_ticket

      live "/projects/:id/current_iteration/edit_ticket/:ticket_id",
           ProjectLive.ShowCurrentIteration,
           :edit_ticket

      live "/projects/:id/backlog", ProjectLive.ShowBacklog, :show

      live "/projects/:id/backlog/new_ticket",
           ProjectLive.ShowBacklog,
           :new_ticket

      live "/projects/:id/backlog/edit_ticket/:ticket_id",
           ProjectLive.ShowBacklog,
           :edit_ticket
    end
  end

  scope "/", ExtickWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ExtickWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
