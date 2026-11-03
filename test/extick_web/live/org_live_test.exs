defmodule ExtickWeb.OrgLiveTest do
  use ExtickWeb.ConnCase

  import Phoenix.LiveViewTest
  import Extick.OrgsFixtures

  @create_attrs %{name: "some name"}
  @invalid_attrs %{name: nil}

  describe "Index" do
    setup [:register_and_log_in_user]

    test "lists the orgs the user is a member of", %{conn: conn, user: user} do
      org = org_fixture(user: user, name: "joined org")
      _other_org = org_fixture(name: "other org")

      {:ok, index_live, html} = live(conn, ~p"/orgs")

      assert html =~ "Your Organizations"
      assert has_element?(index_live, "#orgs-#{org.id}", "joined org")
      refute html =~ "other org"
    end

    test "saves new org", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/orgs")

      assert index_live |> element("a", "New Organization") |> render_click() =~
               "New Organization"

      assert_patch(index_live, ~p"/orgs/new")

      assert index_live
             |> form("#org-form", org: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#org-form", org: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/orgs")

      html = render(index_live)
      assert html =~ "Org created successfully"
      assert html =~ "some name"
    end
  end
end
