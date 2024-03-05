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
  end

  defp validate_key(changeset) do
    changeset
    |> validate_format(:key, ~r/^[A-Z]+$/, message: "must be uppercase")
    |> validate_length(:key, min: 3, max: 20)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        org_id = get_field(changeset, :org_id)

        validate_change(changeset, :key, fn _, key ->
          case Extick.Projects.get_project_by_key(org_id, key) do
            nil -> []
            _ -> [{:key, "has already been taken"}]
          end
        end)

      changeset ->
        changeset
    end
  end

  defp validate_type(changeset) do
    changeset
    |> validate_inclusion(:type, ["scrum"])
  end
end
