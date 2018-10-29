defmodule BayberryWeb.Administration.DashboardView do
  use BayberryWeb, :view
  alias BayberryWeb.Endpoint

  def rabbitmq_dashboard do
    "http://#{Application.get_env(:bayberry, Endpoint)[:rabbitmq]}:15672"
  end
end
