defmodule Extick.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Extick.Tickets` context.
  """

  import Extick.AccountsFixtures
  import Extick.ProjectsFixtures

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {project, attrs} = Map.pop_lazy(Map.new(attrs), :project, fn -> project_fixture() end)

    {:ok, ticket} =
      Extick.Tickets.create_ticket(
        project,
        Enum.into(attrs, %{
          description: "some description",
          priority: 3,
          status: "open",
          title: "some title",
          type: "story"
        })
      )

    ticket
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)
    {ticket, attrs} = Map.pop_lazy(attrs, :ticket, fn -> ticket_fixture() end)
    {author, attrs} = Map.pop_lazy(attrs, :author, fn -> user_fixture() end)

    {:ok, comment} =
      Extick.Tickets.create_comment(
        ticket,
        author,
        Enum.into(attrs, %{
          content: "some content"
        })
      )

    comment
  end
end
