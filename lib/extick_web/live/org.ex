defmodule ExtickWeb.Org do
  use ExtickWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  def on_mount(:require_current_org, _params, session, socket) do
    case session["current_org_id"] do
      nil -> {:halt, redirect(socket, to: ~p"/orgs")}
      current_org_id -> {:cont, Phoenix.Component.assign(socket, current_org_id: current_org_id)}
    end
  end

  def require_current_org(conn, _opts) do
    if get_session(conn, :current_org_id) do
      conn
    else
      conn
      |> put_flash(:error, "You must select an organization to access this page.")
      |> redirect(to: ~p"/orgs")
      |> halt()
    end
  end
end
