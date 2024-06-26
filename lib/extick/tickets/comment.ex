defmodule Extick.Tickets.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Extick.Tickets.Ticket
  alias Extick.Accounts.User

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "comments" do
    field :content, :string
    belongs_to :ticket, Ticket, type: :string
    belongs_to :author, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
