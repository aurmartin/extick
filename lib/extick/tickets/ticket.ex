defmodule Extick.Tickets.Ticket do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Extick.Tickets

  @primary_key {:id, :string, autogenerate: false}
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

    has_many :comments, Extick.Tickets.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def creation_changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [
      :type,
      :title,
      :description,
      :status,
      :priority,
      :reporter_id,
      :assignee_id
    ])
    |> validate_required([:type, :title, :priority, :status])
    |> validate_inclusion(:status, Tickets.statuses(ticket.project))
    |> validate_inclusion(:type, Tickets.types())
    |> validate_inclusion(:priority, Tickets.priorities())
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
    |> validate_inclusion(:status, Tickets.statuses(ticket.project))
    |> validate_inclusion(:type, Tickets.types())
    |> validate_inclusion(:priority, Tickets.priorities())
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
