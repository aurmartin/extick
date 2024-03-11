defmodule Extick.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Extick.Tickets` context.
  """

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> Enum.into(%{
        description: "some description",
        status: "some status",
        title: "some title"
      })
      |> Extick.Tickets.create_ticket()

    ticket
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> Extick.Tickets.create_comment()

    comment
  end
end
