defmodule Extick.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Extick.Projects.Iteration
  alias Extick.Repo

  alias Extick.Projects.Project
  alias Extick.Tickets

  # Projects

  def list_projects_by_org(org_id) do
    Repo.all(from p in Project, where: p.org_id == ^org_id)
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def get_project_by_key(org_id, key) do
    Repo.get_by(Project, org_id: org_id, key: key)
  end

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

  # Database getters

  def get_iteration!(id) when is_binary(id), do: Repo.get!(Iteration, id)

  def find_current_iteration(%Project{} = project) do
    Iteration.current_iteration_query(project)
    |> Repo.one()
  end

  def list_iterations_by_project_and_statuses(project_id, statuses)
      when is_binary(project_id) and is_list(statuses) do
    Iteration.list_by_project_query_and_statuses(project_id, statuses)
    |> Repo.all()
  end

  # Database updates

  def create_iteration(attrs \\ %{}) do
    %Iteration{}
    |> Iteration.creation_changeset(attrs)
    |> Repo.insert()
  end

  def update_iteration(%Iteration{} = iteration, attrs) do
    Iteration.update_changeset(iteration, attrs)
    |> Repo.update()
  end

  def complete_iteration(%Iteration{} = iteration) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :iteration,
      Iteration.update_changeset(iteration, %{status: "completed"})
    )
    |> Ecto.Multi.update_all(
      :tickets,
      Ecto.Query.from(t in Tickets.Ticket,
        where: t.iteration_id == ^iteration.id and t.status != "done"
      ),
      set: [iteration_id: nil]
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{iteration: iteration}} -> {:ok, iteration}
      {:error, error} -> {:error, error}
    end
  end
end
