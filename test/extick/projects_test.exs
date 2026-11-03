defmodule Extick.ProjectsTest do
  use Extick.DataCase

  alias Extick.Projects

  import Extick.OrgsFixtures
  import Extick.ProjectsFixtures

  describe "projects" do
    alias Extick.Projects.Project

    @invalid_attrs %{name: nil, description: nil, key: nil}

    test "list_projects_by_org/1 returns the projects of the org" do
      project = project_fixture()
      _other_project = project_fixture()

      assert Projects.list_projects_by_org(project.org_id) == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      org = org_fixture()

      valid_attrs = %{
        name: "some name",
        description: "some description",
        key: "SOMEKEY",
        type: "scrum",
        org_id: org.id
      }

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.name == "some name"
      assert project.description == "some description"
      assert project.key == "SOMEKEY"
      assert project.type == "scrum"
      assert project.org_id == org.id
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        key: "UPDATEDKEY"
      }

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.name == "some updated name"
      assert project.description == "some updated description"
      assert project.key == "UPDATEDKEY"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
