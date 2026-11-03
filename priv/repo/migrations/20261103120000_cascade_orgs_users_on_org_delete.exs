defmodule Extick.Repo.Migrations.CascadeOrgsUsersOnOrgDelete do
  use Ecto.Migration

  def change do
    alter table(:orgs_users) do
      modify :org_id, references(:orgs, type: :binary_id, on_delete: :delete_all),
        null: false,
        from: {references(:orgs, type: :binary_id), null: false}
    end
  end
end
