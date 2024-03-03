defmodule Extick.Tickets do
  @moduledoc """
  The Tickets context.
  """

  import Ecto.Query, warn: false
  alias Extick.Repo

  alias Extick.Tickets.Ticket

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets()
      [%Ticket{}, ...]

  """
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
    query =
      from t in Ticket,
        where: t.project_id == ^project_id,
        order_by: [desc: t.inserted_at],
        select: t

    query
    |> Repo.all()
    |> Repo.preload([:reporter, :assignee])
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(123)
      %Ticket{}

      iex> get_ticket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket!(id), do: Repo.get!(Ticket, id)

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(%{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticket.

  ## Examples

      iex> delete_ticket(ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(ticket)
      %Ecto.Changeset{data: %Ticket{}}

  """
  def change_ticket(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.creation_changeset(ticket, attrs)
  end

  def all_statuses do
    Ticket.ticket_statuses()
  end

  def format_status(status) do
    status
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def all_types do
    Ticket.ticket_types()
  end

  def format_type(type) do
    type
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def all_priorities do
    Ticket.ticket_priorities()
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
