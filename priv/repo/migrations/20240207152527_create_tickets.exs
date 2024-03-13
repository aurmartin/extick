defmodule Extick.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :string, primary_key: true
      add :type, :string
      add :title, :string
      add :description, :string
      add :status, :string
      add :priority, :integer

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all)
      add :iteration_id, references(:iterations, type: :binary_id, on_delete: :nothing)
      add :reporter_id, references(:users, type: :binary_id, on_delete: :nothing)
      add :assignee_id, references(:users, type: :binary_id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
