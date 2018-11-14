defmodule BayberryWeb.Administration.DashboardView do
  import Application, only: [get_env: 2]
  use BayberryWeb, :view

  def rabbitmq_dashboard do
    "http://#{get_env(:bayberry, :rabbitmq)[:host]}:15672"
  end
end
