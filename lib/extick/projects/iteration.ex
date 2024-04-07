defmodule Extick.Projects.Iteration do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Extick.Projects.Project

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "iterations" do
    field :name, :string
    field :status, :string
    field :start_date, :date
    field :end_date, :date

    belongs_to :project, Extick.Projects.Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def creation_changeset(iteration, attrs) do
    iteration
    |> cast(attrs, [:project_id, :name, :status, :start_date, :end_date])
    |> validate_required([:project_id, :name, :status, :start_date, :end_date])
    |> validate_inclusion(:status, iteration_statuses())
  end

  def update_changeset(iteration, attrs) do
    iteration
    |> cast(attrs, [:name, :status, :start_date, :end_date])
    |> validate_required([:name, :status, :start_date, :end_date])
    |> validate_inclusion(:status, iteration_statuses())
  end

  def iteration_statuses do
    ["planned", "active", "completed"]
  end

  def current_iteration_query(%Project{} = project) do
    from(i in Extick.Projects.Iteration,
      where: i.project_id == ^project.id,
      where: i.status == "active"
    )
  end

  def list_by_project_query_and_statuses(project_id, statuses) do
    from(i in Extick.Projects.Iteration,
      where: i.project_id == ^project_id,
      where: i.status in ^statuses,
      order_by: [desc: i.start_date]
    )
  end
end
