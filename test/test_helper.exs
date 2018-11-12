phantomjs = "#{System.cwd()}/assets/node_modules/phantomjs-prebuilt/bin/phantomjs"
port =
  {:spawn_executable, phantomjs}
  |> Port.open([{:args, ["--wd"]}, :stream, :binary])

{:os_pid, _pid} = Port.info(port, :os_pid)

Application.ensure_all_started(:hound)
ExUnit.start(exclude: [:acceptance])
Ecto.Adapters.SQL.Sandbox.mode(Bayberry.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Bayberry.Geolocation, :manual)
