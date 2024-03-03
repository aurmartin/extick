defmodule Extick.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :description, :string
      add :status, :string

      add :project_id, references(:projects, on_delete: :delete_all)
      add :reporter_id, references(:users, on_delete: :nothing)
      add :assignee_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
