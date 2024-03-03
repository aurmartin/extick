defmodule Extick.Orgs.Org do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orgs" do
    field :name, :string

    many_to_many :members, Extick.Accounts.User,
      join_through: Extick.Orgs.OrgUser,
      on_replace: :delete

    has_many :projects, Extick.Projects.Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
