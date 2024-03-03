defmodule Extick.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :key, :string, null: false, unique: true
      add :name, :string, null: false
      add :description, :string, null: false
      add :org_id, references(:orgs, type: :binary_id), null: false
      add :default_board_id, references(:boards, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:projects, [:key])
  end
end
