defmodule Swai.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  @moduledoc"""
  The main application module for Swai.
  """

  use Application

  require Logger

  @impl true
  def start(_type, _args) do

    children = [
      Swai.Repo,
      {DNSCluster, query: Application.get_env(:swai, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Swai.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Swai.Finch},
      Swai.CachesSystem
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Swai.Supervisor)
  end






end
