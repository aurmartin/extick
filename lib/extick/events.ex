defmodule Extick.Events do
  @moduledoc """
  Define Event structs for use within the pubsub system.
  """

  defmodule CommentAdded do
    defstruct comment: nil
  end

  defmodule TicketAdded do
    defstruct ticket: nil
  end

  defmodule TicketUpdated do
    defstruct ticket: nil, changeset: nil
  end

  defmodule TicketDeleted do
    defstruct ticket: nil
  end
end
