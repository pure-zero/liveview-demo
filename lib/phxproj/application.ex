defmodule Phxproj.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhxprojWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phxproj, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Phxproj.PubSub},
      # Start a worker by calling: Phxproj.Worker.start_link(arg)
      # {Phxproj.Worker, arg},
      # Start to serve requests, typically the last entry
      PhxprojWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phxproj.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxprojWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
