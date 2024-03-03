defmodule Extick.Orgs do
  @moduledoc """
  The Orgs context.
  """

  import Ecto.Query, warn: false
  alias Extick.Repo

  alias Extick.Orgs.Org
  alias Extick.Orgs.OrgUser
  alias Extick.Accounts.User

  def list_joined_orgs(user_id) do
    Repo.all(from o in Org, join: m in assoc(o, :members), where: m.id == ^user_id)
  end

  def get_org(id), do: Repo.get(Org, id)
  def get_org!(id), do: Repo.get!(Org, id)

  def create_org(%User{} = user, attrs \\ %{}) do
    with {:ok, org} <- create_empty_org(attrs) do
      add_member(org, user)
    end
  end

  defp create_empty_org(attrs) do
    %Org{} |> Org.changeset(attrs) |> Repo.insert()
  end

  def update_org(%Org{} = org, attrs) do
    org
    |> Org.changeset(attrs)
    |> Repo.update()
  end

  def add_member(%Org{} = org, %User{} = user) do
    with nil <- Repo.get_by(OrgUser, org_id: org.id, user_id: user.id),
         {:ok, _} <- Repo.insert(%OrgUser{org_id: org.id, user_id: user.id}) do
      {:ok, org}
    else
      %OrgUser{} ->
        {:error, "User is already a member"}
    end
  end

  def remove_member(%Org{} = org, %User{} = user) do
    {1, nil} =
      Repo.delete_all(from ou in OrgUser, where: ou.org_id == ^org.id and ou.user_id == ^user.id)

    org
  end

  def delete_org(%Org{} = org) do
    Repo.delete(org)
  end

  def change_org(%Org{} = org, attrs \\ %{}) do
    Org.changeset(org, attrs)
  end
end
