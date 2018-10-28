defmodule Mix.Tasks.Phx.Npm.Install do
  use Mix.Task
  @assets "assets"

  @shortdoc "Install JavaScript dependencies with npm"
  @recursive true

  @moduledoc """
  Installs npm packages.

    mix phx.npm.install

  Installed packages are located in assets/node_mobules.
  """

  @doc false
  def run(_) do
    case System.cmd("which", ["npm"]) do
      {_, 1} ->
        Mix.shell().error("npm not found.")

      {npm, 0} ->
        args = ["install", "--no-optional"]

        case System.cmd(String.trim(npm), args, cd: @assets) do
          {_, 0} -> IO.puts("Installed npm packages.")
          _ -> Mix.shell().error("npm install failed.")
        end
    end
  end
end
