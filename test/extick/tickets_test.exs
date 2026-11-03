defmodule Extick.TicketsTest do
  use Extick.DataCase

  alias Extick.Tickets

  import Extick.AccountsFixtures
  import Extick.ProjectsFixtures
  import Extick.TicketsFixtures

  describe "tickets" do
    alias Extick.Tickets.Ticket

    @valid_attrs %{
      type: "story",
      title: "some title",
      description: "some description",
      status: "open",
      priority: 3
    }
    @invalid_attrs %{type: nil, status: nil, title: nil, priority: nil}

    test "list_tickets_by_project/1 returns the tickets of the project" do
      ticket = ticket_fixture()
      _other_ticket = ticket_fixture()

      assert [%Ticket{id: id}] = Tickets.list_tickets_by_project(ticket.project_id)
      assert id == ticket.id
    end

    test "get_ticket!/1 returns the ticket with given id" do
      ticket = ticket_fixture()
      assert Tickets.get_ticket!(ticket.id).title == ticket.title
    end

    test "create_ticket/2 with valid data creates a ticket" do
      project = project_fixture()

      assert {:ok, %Ticket{} = ticket} = Tickets.create_ticket(project, @valid_attrs)
      assert ticket.type == "story"
      assert ticket.title == "some title"
      assert ticket.description == "some description"
      assert ticket.status == "open"
      assert ticket.priority == 3
      assert ticket.project_id == project.id
    end

    test "create_ticket/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Tickets.create_ticket(project_fixture(), @invalid_attrs)
    end

    test "update_ticket/2 with valid data updates the ticket" do
      ticket = ticket_fixture()

      update_attrs = %{
        status: "in_progress",
        description: "some updated description",
        title: "some updated title",
        priority: 5
      }

      assert {:ok, %Ticket{} = ticket} = Tickets.update_ticket(ticket, update_attrs)
      assert ticket.status == "in_progress"
      assert ticket.description == "some updated description"
      assert ticket.title == "some updated title"
      assert ticket.priority == 5
    end

    test "update_ticket/2 with invalid data returns error changeset" do
      ticket = ticket_fixture()
      assert {:error, %Ecto.Changeset{}} = Tickets.update_ticket(ticket, @invalid_attrs)
      assert Tickets.get_ticket!(ticket.id).title == ticket.title
    end

    test "delete_ticket/1 deletes the ticket" do
      ticket = ticket_fixture()
      assert {:ok, %Ticket{}} = Tickets.delete_ticket(ticket)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_ticket!(ticket.id) end
    end

    test "change_ticket/1 returns a ticket changeset" do
      ticket = ticket_fixture()
      assert %Ecto.Changeset{} = Tickets.change_ticket(ticket)
    end
  end

  describe "comments" do
    alias Extick.Tickets.Comment

    @invalid_attrs %{content: nil}

    test "list_comments/1 returns the comments of the ticket" do
      ticket = ticket_fixture()
      comment = comment_fixture(ticket: ticket)
      _other_comment = comment_fixture()

      assert [%Comment{id: id}] = Tickets.list_comments(ticket)
      assert id == comment.id
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Tickets.get_comment!(comment.id).content == comment.content
    end

    test "create_comment/3 with valid data creates a comment" do
      ticket = ticket_fixture()
      author = user_fixture()

      assert {:ok, %Comment{} = comment} =
               Tickets.create_comment(ticket, author, %{content: "some content"})

      assert comment.content == "some content"
      assert comment.ticket_id == ticket.id
      assert comment.author_id == author.id
    end

    test "create_comment/3 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Tickets.create_comment(ticket_fixture(), user_fixture(), @invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Tickets.update_comment(comment, update_attrs)
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Tickets.update_comment(comment, @invalid_attrs)
      assert Tickets.get_comment!(comment.id).content == comment.content
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Tickets.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Tickets.change_comment(comment)
    end
  end
end
