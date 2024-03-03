defmodule ExtickWeb.OrgLiveTest do
  use ExtickWeb.ConnCase

  import Phoenix.LiveViewTest
  import Extick.OrgsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_org(_) do
    org = org_fixture()
    %{org: org}
  end

  describe "Index" do
    setup [:create_org]

    test "lists all orgs", %{conn: conn, org: org} do
      {:ok, _index_live, html} = live(conn, ~p"/orgs")

      assert html =~ "Listing Orgs"
      assert html =~ org.name
    end

    test "saves new org", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/orgs")

      assert index_live |> element("a", "New Org") |> render_click() =~
               "New Org"

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

    test "updates org in listing", %{conn: conn, org: org} do
      {:ok, index_live, _html} = live(conn, ~p"/orgs")

      assert index_live |> element("#orgs-#{org.id} a", "Edit") |> render_click() =~
               "Edit Org"

      assert_patch(index_live, ~p"/orgs/#{org}/edit")

      assert index_live
             |> form("#org-form", org: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#org-form", org: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/orgs")

      html = render(index_live)
      assert html =~ "Org updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes org in listing", %{conn: conn, org: org} do
      {:ok, index_live, _html} = live(conn, ~p"/orgs")

      assert index_live |> element("#orgs-#{org.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#orgs-#{org.id}")
    end
  end

  describe "Show" do
    setup [:create_org]

    test "displays org", %{conn: conn, org: org} do
      {:ok, _show_live, html} = live(conn, ~p"/orgs/#{org}")

      assert html =~ "Show Org"
      assert html =~ org.name
    end

    test "updates org within modal", %{conn: conn, org: org} do
      {:ok, show_live, _html} = live(conn, ~p"/orgs/#{org}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Org"

      assert_patch(show_live, ~p"/orgs/#{org}/show/edit")

      assert show_live
             |> form("#org-form", org: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#org-form", org: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/orgs/#{org}")

      html = render(show_live)
      assert html =~ "Org updated successfully"
      assert html =~ "some updated name"
    end
  end
end
