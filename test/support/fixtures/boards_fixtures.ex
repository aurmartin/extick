defmodule Extick.BoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Extick.Boards` context.
  """

  @doc """
  Generate a board.
  """
  def board_fixture(attrs \\ %{}) do
    {:ok, board} =
      attrs
      |> Enum.into(%{
        name: "some name",
        type: "some type"
      })
      |> Extick.Boards.create_board()

    board
  end
end
