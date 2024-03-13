defmodule Extick.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :string
      add :ticket_id, references(:tickets, type: :string, on_delete: :delete_all)
      add :author_id, references(:users, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
