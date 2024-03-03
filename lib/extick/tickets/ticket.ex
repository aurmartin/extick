defmodule Extick.Tickets.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tickets" do
    field :title, :string
    field :description, :string
    field :status, :string

    belongs_to :project, Extick.Projects.Project
    belongs_to :reporter, Extick.Accounts.User
    belongs_to :assignee, Extick.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:title, :description, :status, :project_id, :reporter_id, :assignee_id])
    |> validate_required([:title, :description, :status, :project_id, :reporter_id, :assignee_id])
    |> validate_inclusion(:status, ticket_statuses())
  end

  def ticket_statuses do
    ["backlog", "open", "in_progress", "done"]
  end
end
