defmodule Extick.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Extick.Projects.Iteration
  alias Extick.Repo

  alias Extick.Projects.Project

  # Projects

  def list_projects_by_org(org_id) do
    Repo.all(from p in Project, where: p.org_id == ^org_id)
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
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

  # Iterations

  def create_iteration(attrs \\ %{}) do
    %Iteration{}
    |> Iteration.creation_changeset(attrs)
    |> Repo.insert()
  end

  def update_iteration(%Iteration{} = iteration, attrs) do
    Iteration.update_changeset(iteration, attrs)
    |> Repo.update()
  end

  def find_current_iteration(project) do
    Iteration.current_iteration_query(project)
    |> Repo.one()
  end

  def list_iterations_by_project_and_statuses(project_id, statuses) do
    Iteration.list_by_project_query_and_statuses(project_id, statuses)
    |> Repo.all()
  end

  def get_iteration!(id), do: Repo.get!(Iteration, id)
end
