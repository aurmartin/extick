defmodule Devutils.Data.Tickets do
  alias Extick.Projects
  alias Extick.Tickets

  @title_desc [
    {
      "Fast trip search",
      "We need to implement a fast trip search feature to allow users to find trips quickly."
    },
    {
      "Technical alerting",
      "We need to implement a technical alerting system to notify the technical team of any issues."
    },
    {
      "New user onboarding",
      "We need to implement a new user onboarding process to allow new users to sign up and start using the system."
    },
    {
      "Performance monitoring",
      "We need to implement a performance monitoring system to monitor the performance of the system."
    },
    {
      "User authentication",
      "We need to implement a user authentication system to allow users to log in and use the system."
    },
    {
      "Billing system integration - fronted",
      "We need to integrate the billing system with the frontend to allow users to manage their bills."
    },
    {
      "Billing system integration - backend",
      "We need to integrate the billing system with the backend to allow the system to manage bills."
    },
    {
      "User profile management",
      "We need to implement a user profile management system to allow users to manage their profiles."
    },
    {
      "Adapt users management to new requirements",
      "We need to adapt the users management system to new requirements."
    },
    {
      "User roles management",
      "We need to implement a user roles management system to allow users to manage their roles."
    },
    {
      "User permissions management",
      "We need to implement a user permissions management system to allow users to manage their permissions."
    },
    {
      "User groups management",
      "We need to implement a user groups management system to allow users to manage their groups."
    },
    {
      "List bills",
      "We need to implement a list bills feature to allow users to list their bills."
    },
    {
      "Pay bills",
      "We need to implement a pay bills feature to allow users to pay their bills."
    },
    {
      "Cancel bills",
      "We need to implement a cancel bills feature to allow users to cancel their bills."
    },
    {
      "Refund bills",
      "We need to implement a refund bills feature to allow users to refund their bills."
    },
    {
      "Delete bills",
      "We need to implement a delete bills feature to allow users to delete their bills."
    },
    {
      "Update bills",
      "We need to implement an update bills feature to allow users to update their bills."
    },
    {
      "List invoices",
      "We need to implement a list invoices feature to allow users to list their invoices."
    },
    {
      "Pay invoices",
      "We need to implement a pay invoices feature to allow users to pay their invoices."
    },
    {
      "Cancel invoices",
      "We need to implement a cancel invoices feature to allow users to cancel their invoices."
    },
    {
      "Refund invoices",
      "We need to implement a refund invoices feature to allow users to refund their invoices."
    },
    {
      "Delete invoices",
      "We need to implement a delete invoices feature to allow users to delete their invoices."
    }
  ]

  def generate_ticket(project) do
    {title, desc} = Enum.random(@title_desc)

    %{
      project: project,
      type: Enum.random(Tickets.types()),
      title: title,
      description: desc,
      status: Enum.random(Tickets.statuses(project)),
      priority: Enum.random(Tickets.priorities())
    }
  end

  def generate_tickets(project_id, n) do
    project = Projects.get_project!(project_id)

    Enum.map(1..n, fn _ -> generate_ticket(project) end)
    |> Enum.map(&Tickets.create_ticket(project, &1))
  end
end

defmodule Devutils.Data.Projects do
  @name [
    "Order Capture & Sourcing",
    "Order Management",
    "Order Fulfillment",
    "Extended Supply",
    "Customer Service",
    "LV Finor",
    "LV Finor - Frontend",
    "LV Finor - Backend",
    "LV Finor - Mobile"
  ]

  defp random_key do
    letters =
      [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z"
      ]

    Enum.random(letters) <> Enum.random(letters) <> Enum.random(letters)
  end

  def generate_project(org) do
    %{
      name: Enum.random(@name),
      key: random_key(),
      description: "This is a project description",
      type: "scrum",
      org_id: org.id
    }
  end

  def generate_projects(org_id, i, j) do
    org = Extick.Orgs.get_org!(org_id)

    Enum.map(1..i, fn _ -> generate_project(org) end)
    |> Enum.map(fn params ->
      {:ok, x} = Extick.Projects.create_project(params)
      x
    end)
    |> Enum.each(&Devutils.Data.Tickets.generate_tickets(&1.id, j))
  end
end
