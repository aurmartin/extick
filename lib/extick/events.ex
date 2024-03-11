defmodule Extick.Events do
  @moduledoc """
  Define Event structs for use within the pubsub system.
  """

  defmodule CommentAdded do
    defstruct comment: nil
  end
end
