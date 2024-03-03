# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Extick.Repo.insert!(%Extick.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Extick.Accounts

users = [
  %{
    email: "aurmartin@pm.me",
    name: "Aurélien Martin",
    password: "password"
  },
  %{
    email: "toto@pm.me",
    name: "Toto",
    password: "password"
  }
]

users =
  Enum.map(users, fn user ->
    {:ok, user} = Accounts.register_user(user)
    user
  end)

alias Extick.Orgs

orgs = [
  %{
    name: "DevOrg"
  }
]

orgs =
  Enum.map(orgs, fn org ->
    {:ok, org} = Orgs.create_org(Enum.at(users, 0), org)
    org
  end)

alias Extick.Projects

projects = [
  %{
    key: "PRO",
    name: "Project",
    description: "Project description",
    org_id: Enum.at(orgs, 0).id
  },
  %{
    key: "EXT",
    name: "Extick",
    description: "Extick description",
    org_id: Enum.at(orgs, 0).id
  }
]

projects =
  Enum.map(projects, fn project ->
    {:ok, project} = Projects.create_project(project)
    project
  end)

alias Extick.Tickets

project = Enum.at(projects, 0)
reporter = Enum.at(users, 0)
assignee = Enum.at(users, 1)

tickets = [
  %{
    title: "Ticket 1",
    description: "Ticket 1 description",
    status: "backlog",
    project_id: project.id,
    reporter_id: reporter.id,
    assignee_id: assignee.id
  },
  %{
    title: "Ticket 2",
    description: "Ticket 2 description",
    status: "open",
    project_id: project.id,
    reporter_id: reporter.id,
    assignee_id: assignee.id
  }
]

tickets =
  Enum.map(tickets, fn ticket ->
    {:ok, ticket} = Tickets.create_ticket(ticket)
    ticket
  end)
