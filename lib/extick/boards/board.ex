defmodule Extick.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "boards" do
    field :name, :string
    field :type, :string

    belongs_to :project, Extick.Projects.Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :type, :project_id])
    |> validate_required([:name, :type, :project_id])
    |> validate_inclusion(:type, board_types())
  end

  def board_types do
    ["kanban"]
  end
end
