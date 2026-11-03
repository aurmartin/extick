defmodule ExtickWeb.ProjectLiveTest do
  use ExtickWeb.ConnCase

  import Phoenix.LiveViewTest
  import Extick.OrgsFixtures
  import Extick.ProjectsFixtures

  alias Extick.Projects

  @create_attrs %{name: "some name", description: "some description", key: "NEWKEY"}
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    key: "UPDATEDKEY"
  }
  @invalid_attrs %{name: nil, description: nil, key: nil}

  defp select_org(%{conn: conn, user: user}) do
    org = org_fixture(user: user)
    %{conn: Plug.Conn.put_session(conn, :current_org_id, org.id), org: org}
  end

  defp create_project(%{org: org}) do
    %{project: project_fixture(org_id: org.id)}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :select_org, :create_project]

    test "lists the projects of the selected org", %{conn: conn, project: project} do
      other_project = project_fixture(name: "other project")

      {:ok, index_live, html} = live(conn, ~p"/projects")

      assert html =~ "Listing Projects"
      assert has_element?(index_live, "#projects-#{project.id}", project.name)
      refute has_element?(index_live, "#projects-#{other_project.id}")
    end

    test "updates project in listing", %{conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")

      assert index_live |> element("#projects-#{project.id} a", "Edit") |> render_click() =~
               "Edit Project"

      assert_patch(index_live, ~p"/projects/#{project}/edit")

      assert index_live
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _index_live, html} =
        index_live
        |> form("#project-form", project: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/projects")

      assert html =~ "Project updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes project in listing", %{conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")

      assert index_live |> element("#projects-#{project.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#projects-#{project.id}")
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end
  end

  describe "New" do
    setup [:register_and_log_in_user, :select_org]

    test "creates a scrum project in the selected org", %{conn: conn, org: org} do
      {:ok, new_live, html} = live(conn, ~p"/projects/new")

      assert html =~ "Select your project type"

      assert new_live |> element("[phx-value-type=scrum]") |> render_click() =~
               "Enter your project details"

      assert new_live
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _index_live, html} =
        new_live
        |> form("#project-form", project: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/projects")

      assert html =~ "Project created successfully"
      assert html =~ "some name"
      assert %{type: "scrum"} = Projects.get_project_by_key(org.id, "NEWKEY")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :select_org, :create_project]

    test "redirects a scrum project to its current iteration", %{conn: conn, project: project} do
      assert {:error, {:redirect, %{to: path}}} = live(conn, ~p"/projects/#{project}")
      assert path == ~p"/projects/#{project}/current_iteration"
    end
  end
end
