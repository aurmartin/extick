defmodule Extick.Orgs.OrgUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "orgs_users" do
    belongs_to :org, Extick.Orgs.Org
    belongs_to :user, Extick.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(org_user, attrs) do
    org_user
    |> cast(attrs, [:org_id, :user_id])
  end
end
