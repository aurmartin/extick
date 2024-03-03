defmodule Extick.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Extick.Repo

  alias Extick.Projects.Project
  alias Extick.Boards

  def list_projects_by_owner(owner_id) do
    Repo.all(from p in Project, where: p.owner_id == ^owner_id)
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def create_project(attrs \\ %{}) do
    with {:ok, project} <- create_empty_project(attrs) do
      {:ok, project} = init_project!(project)
      {:ok, project}
    end
  end

  defp create_empty_project(attrs) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  defp init_project!(%Project{} = project) do
    {:ok, board} =
      Boards.create_board(%{
        "name" => "Default Board",
        "type" => "kanban",
        "project_id" => project.id
      })

    {:ok, project} = set_default_board(project, %{"default_board_id" => board.id})

    {:ok, project}
  end

  def set_default_board(%Project{} = project, attrs) do
    project
    |> Project.set_default_board_changeset(attrs)
    |> Repo.update()
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
