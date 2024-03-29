defmodule Extick.Tickets.Ticket do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tickets" do
    field :type, :string
    field :title, :string
    field :description, :string, default: ""
    field :status, :string
    field :priority, :integer

    belongs_to :project, Extick.Projects.Project
    belongs_to :iteration, Extick.Projects.Iteration
    belongs_to :reporter, Extick.Accounts.User
    belongs_to :assignee, Extick.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def creation_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [
      :type,
      :project_id,
      :title,
      :description,
      :status,
      :priority,
      :reporter_id,
      :assignee_id
    ])
    |> validate_required([:type, :project_id, :title, :priority, :status])
    |> validate_inclusion(:status, ticket_statuses())
    |> validate_inclusion(:type, ticket_types())
    |> validate_inclusion(:priority, ticket_priorities())
  end

  def update_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [
      :title,
      :description,
      :status,
      :priority,
      :reporter_id,
      :assignee_id,
      :iteration_id
    ])
    |> validate_required([:title, :priority, :status])
    |> validate_inclusion(:status, ticket_statuses())
    |> validate_inclusion(:type, ticket_types())
    |> validate_inclusion(:priority, ticket_priorities())
  end

  def ticket_statuses do
    ["backlog", "open", "in_progress", "done"]
  end

  def ticket_types do
    ["story", "enabler", "bug"]
  end

  def ticket_priorities do
    [1, 2, 3, 4, 5]
  end

  def list_by_iteration_query(iteration_id) do
    from(t in Extick.Tickets.Ticket,
      where: t.iteration_id == ^iteration_id,
      order_by: [desc: t.inserted_at],
      select: t
    )
  end

  def list_by_project_query(project_id) do
    from(t in Extick.Tickets.Ticket,
      where: t.project_id == ^project_id,
      order_by: [desc: t.inserted_at],
      select: t
    )
  end
end
