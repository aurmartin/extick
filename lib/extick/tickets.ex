defmodule Extick.Tickets do
  import Ecto.Query, warn: false

  alias Extick.{Repo, Events}
  alias Extick.Tickets.{Ticket, Comment}
  alias Extick.Accounts.User
  alias Extick.Projects.Project

  # Tickets

  def tickets_subscribe(%Project{} = project) do
    Phoenix.PubSub.subscribe(Extick.PubSub, tickets_topic(project))
  end

  def tickets_topic(%Project{} = project) do
    "project:#{project.id}:tickets"
  end

  def tickets_topic(%Ticket{} = ticket) do
    "project:#{ticket.project_id}:tickets"
  end

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
      {:ok, %{ticket: ticket}} ->
        :ok =
          Phoenix.PubSub.broadcast(
            Extick.PubSub,
            tickets_topic(ticket),
            {__MODULE__, %Events.TicketAdded{ticket: ticket}}
          )

        {:ok, ticket}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_ticket(%Ticket{} = ticket, attrs) do
    changeset =
      ticket
      |> Repo.preload(:project)
      |> Ticket.update_changeset(attrs)

    changeset
    |> Repo.update()
    |> case do
      {:ok, ticket} ->
        :ok =
          Phoenix.PubSub.broadcast(
            Extick.PubSub,
            tickets_topic(ticket),
            {__MODULE__, %Events.TicketUpdated{ticket: ticket, changeset: changeset}}
          )

        {:ok, ticket}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
    |> case do
      {:ok, ticket} ->
        :ok =
          Phoenix.PubSub.broadcast(
            Extick.PubSub,
            tickets_topic(ticket),
            {__MODULE__, %Events.TicketDeleted{ticket: ticket}}
          )

        {:ok, ticket}

      {:error, changeset} ->
        {:error, changeset}
    end
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
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  def types do
    ["story", "enabler", "bug"]
  end

  def format_type(type) do
    type
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
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

  # Ticket comments

  def comments_subscribe(%Ticket{} = ticket) do
    Phoenix.PubSub.subscribe(Extick.PubSub, comments_topic(ticket))
  end

  defp comments_topic(%Ticket{} = ticket) do
    "ticket:#{ticket.id}:comments"
  end

  def list_comments(%Ticket{id: nil}), do: []

  def list_comments(%Ticket{} = ticket) do
    query = from(c in Comment, where: c.ticket_id == ^ticket.id, order_by: [desc: c.inserted_at])
    Repo.all(query) |> Repo.preload(:author)
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  def create_comment(%Ticket{} = ticket, %User{} = author, attrs \\ %{}) do
    %Comment{ticket: ticket, author: author}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, comment} ->
        :ok =
          Phoenix.PubSub.broadcast(
            Extick.PubSub,
            comments_topic(ticket),
            {__MODULE__, %Events.CommentAdded{comment: comment}}
          )

        {:ok, comment}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
