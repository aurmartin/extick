defmodule Extick.Repo.Migrations.CreateIterations do
  use Ecto.Migration

  def change do
    create table(:iterations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :status, :string
      add :start_date, :date
      add :end_date, :date

      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
