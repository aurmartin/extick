defmodule Devutils.Tickets do
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

  @statuses ["open", "in_progress", "done"]

  @priorities [1, 2, 3, 4, 5]

  def generate_ticket(project_id) do
    {title, desc} = Enum.random(@title_desc)

    %{
      project_id: project_id,
      type: Enum.random(Tickets.all_types()),
      title: title,
      description: desc,
      status: Enum.random(@statuses),
      priority: Enum.random(@priorities)
    }
  end

  def generate_tickets(project_id, n) do
    Enum.map(1..n, fn _ -> generate_ticket(project_id) end)
    |> Enum.map(&Tickets.create_ticket/1)
  end
end
