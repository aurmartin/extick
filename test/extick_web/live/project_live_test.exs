defmodule ExtickWeb.ProjectLiveTest do
  use ExtickWeb.ConnCase

  import Phoenix.LiveViewTest
  import Extick.ProjectsFixtures

  @create_attrs %{name: "some name", description: "some description", key: "some key"}
  @update_attrs %{name: "some updated name", description: "some updated description", key: "some updated key"}
  @invalid_attrs %{name: nil, description: nil, key: nil}

  defp create_project(_) do
    project = project_fixture()
    %{project: project}
  end

  describe "Index" do
    setup [:create_project]

    test "lists all projects", %{conn: conn, project: project} do
      {:ok, _index_live, html} = live(conn, ~p"/projects")

      assert html =~ "Listing Projects"
      assert html =~ project.name
    end

    test "saves new project", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")

      assert index_live |> element("a", "New Project") |> render_click() =~
               "New Project"

      assert_patch(index_live, ~p"/projects/new")

      assert index_live
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#project-form", project: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/projects")

      html = render(index_live)
      assert html =~ "Project created successfully"
      assert html =~ "some name"
    end

    test "updates project in listing", %{conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")

      assert index_live |> element("#projects-#{project.id} a", "Edit") |> render_click() =~
               "Edit Project"

      assert_patch(index_live, ~p"/projects/#{project}/edit")

      assert index_live
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#project-form", project: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/projects")

      html = render(index_live)
      assert html =~ "Project updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes project in listing", %{conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")

      assert index_live |> element("#projects-#{project.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#projects-#{project.id}")
    end
  end

  describe "Show" do
    setup [:create_project]

    test "displays project", %{conn: conn, project: project} do
      {:ok, _show_live, html} = live(conn, ~p"/projects/#{project}")

      assert html =~ "Show Project"
      assert html =~ project.name
    end

    test "updates project within modal", %{conn: conn, project: project} do
      {:ok, show_live, _html} = live(conn, ~p"/projects/#{project}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Project"

      assert_patch(show_live, ~p"/projects/#{project}/show/edit")

      assert show_live
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#project-form", project: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/projects/#{project}")

      html = render(show_live)
      assert html =~ "Project updated successfully"
      assert html =~ "some updated name"
    end
  end
end
