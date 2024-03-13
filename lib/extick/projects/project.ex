defmodule Extick.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "projects" do
    field :name, :string
    field :description, :string
    field :key, :string
    field :type, :string
    field :created_tickets_count, :integer, default: 0
    belongs_to :org, Extick.Orgs.Org

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:key, :name, :description, :type, :org_id])
    |> validate_required([:key, :name, :description, :type, :org_id])
    |> validate_key()
    |> validate_type()
    |> foreign_key_constraint(:org_id)
    |> unique_constraint([:org_id, :key])
  end

  defp validate_key(changeset) do
    changeset
    |> validate_format(:key, ~r/^[A-Z]+$/, message: "must be uppercase")
    |> validate_length(:key, min: 3, max: 20)
  end

  defp validate_type(changeset) do
    changeset
    |> validate_inclusion(:type, ["scrum"])
  end
end
