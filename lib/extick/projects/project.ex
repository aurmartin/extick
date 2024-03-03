defmodule Extick.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :name, :string
    field :description, :string
    field :key, :string
    field :type, :string
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
  end

  defp validate_key(changeset) do
    changeset
    |> validate_format(:key, ~r/^[A-Z]+$/, message: "must be uppercase")
    |> validate_length(:key, min: 3, max: 20)
    |> unsafe_validate_unique(:key, Extick.Repo)
    |> unique_constraint(:key)
  end

  defp validate_type(changeset) do
    changeset
    |> validate_inclusion(:type, ["scrum"])
  end
end
