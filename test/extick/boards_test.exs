defmodule Extick.BoardsTest do
  use Extick.DataCase

  alias Extick.Boards

  describe "boards" do
    alias Extick.Boards.Board

    import Extick.BoardsFixtures

    @invalid_attrs %{name: nil, type: nil}

    test "list_boards/0 returns all boards" do
      board = board_fixture()
      assert Boards.list_boards() == [board]
    end

    test "get_board!/1 returns the board with given id" do
      board = board_fixture()
      assert Boards.get_board!(board.id) == board
    end

    test "create_board/1 with valid data creates a board" do
      valid_attrs = %{name: "some name", type: "some type"}

      assert {:ok, %Board{} = board} = Boards.create_board(valid_attrs)
      assert board.name == "some name"
      assert board.type == "some type"
    end

    test "create_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Boards.create_board(@invalid_attrs)
    end

    test "update_board/2 with valid data updates the board" do
      board = board_fixture()
      update_attrs = %{name: "some updated name", type: "some updated type"}

      assert {:ok, %Board{} = board} = Boards.update_board(board, update_attrs)
      assert board.name == "some updated name"
      assert board.type == "some updated type"
    end

    test "update_board/2 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, %Ecto.Changeset{}} = Boards.update_board(board, @invalid_attrs)
      assert board == Boards.get_board!(board.id)
    end

    test "delete_board/1 deletes the board" do
      board = board_fixture()
      assert {:ok, %Board{}} = Boards.delete_board(board)
      assert_raise Ecto.NoResultsError, fn -> Boards.get_board!(board.id) end
    end

    test "change_board/1 returns a board changeset" do
      board = board_fixture()
      assert %Ecto.Changeset{} = Boards.change_board(board)
    end
  end
end
