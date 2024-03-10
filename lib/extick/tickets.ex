defmodule Extick.Tickets do
  @moduledoc """
  The Tickets context.
  """

  import Ecto.Query, warn: false
  alias Extick.Repo

  alias Extick.Tickets.Ticket
  alias Extick.Projects.Project

  def list_tickets do
    Repo.all(Ticket)
  end

  def list_tickets_by_project_and_statuses(project_id, statuses) do
    query =
      from t in Ticket,
        where: t.project_id == ^project_id and t.status in ^statuses,
        order_by: [desc: t.inserted_at],
        select: t

    query
    |> Repo.all()
    |> Repo.preload([:reporter, :assignee])
  end

  def list_tickets_by_project(project_id) do
    Ticket.list_by_project_query(project_id)
    |> Repo.all()
    |> Repo.preload([:reporter, :assignee])
  end

  def list_tickets_by_iteration(iteration_id) do
    Ticket.list_by_iteration_query(iteration_id)
    |> Repo.all()
    |> Repo.preload([:reporter, :assignee])
  end

  def get_ticket!(id), do: Repo.get!(Ticket, id)

  def create_ticket(%Project{} = project, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:id, fn repo, _changes ->
      query = from(p in Project, where: p.id == ^project.id)
      count = query |> Ecto.Query.select([p], p.created_tickets_count) |> repo.one!()
      repo.update_all(query, inc: [created_tickets_count: 1])

      {:ok, "#{project.key}-#{count + 1}"}
    end)
    |> Ecto.Multi.insert(:ticket, fn %{id: id} ->
      Ticket.creation_changeset(%Ticket{id: id, project: project}, attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{ticket: ticket}} -> {:ok, ticket}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Repo.preload(:project)
    |> Ticket.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_all_tickets(project_id) do
    query = from(t in Ticket, where: t.project_id == ^project_id)
    Repo.delete_all(query)
  end

  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
  end

  def change_ticket(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.creation_changeset(ticket, attrs)
  end

  def statuses(%Project{} = project) do
    case project.type do
      "scrum" -> ["open", "in_progress", "done"]
      "kanban" -> ["backlog", "open", "in_progress", "done"]
    end
  end

  def format_status(status) do
    status
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def types do
    ["story", "enabler", "bug"]
  end

  def format_type(type) do
    type
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def priorities do
    [1, 2, 3, 4, 5]
  end

  def format_priority(priority) do
    case priority do
      1 -> "Low"
      2 -> "Normal"
      3 -> "High"
      4 -> "Urgent"
      5 -> "Immediate"
    end
  end
end
