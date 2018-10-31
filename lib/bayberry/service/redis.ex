defmodule Bayberry.Service.Redis do
  alias Supervisor.Spec

  def worker() do
    host = "storage.datapun.net"
    Spec.worker(Redix, [[host: host, port: 6379, database: 3], [name: :redix]])
  end
end
