defmodule ExtickWeb.OrgController do
  use ExtickWeb, :controller

  def select(conn, %{"id" => id}) do
    conn
    |> put_session(:current_org_id, id)
    |> redirect(to: ~p"/projects")
  end
end
