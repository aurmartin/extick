defmodule ExtickWeb.PageControllerTest do
  use ExtickWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "ExTick is a simple and fast project management system"
  end
end
