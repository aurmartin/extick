defmodule ExtickWeb.Org do
  use ExtickWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  def on_mount(:require_current_org, _params, session, socket) do
    case session["current_org_id"] do
      nil ->
        {:halt, redirect(socket, to: ~p"/orgs")}

      current_org_id ->
        socket =
          Phoenix.Component.assign_new(socket, :current_org, fn ->
            Extick.Orgs.get_org!(current_org_id)
          end)

        {:cont, socket}
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

  def fetch_current_org(conn, _opts) do
    case get_session(conn, :current_org_id) do
      nil ->
        assign(conn, :current_org, nil)

      org_id ->
        org = Extick.Orgs.get_org!(org_id)
        assign(conn, :current_org, org)
    end
  end
end
