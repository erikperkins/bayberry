defmodule Mix.Tasks.Phx.Phantom do
  use Mix.Task
  @assets "assets"
  @phantomjs "node_modules/phantomjs-prebuilt/bin/phantomjs"

  @shortdoc "Run PhantomJS webdriver"
  @recursive true

  @moduledoc """
  Run PhantomJS webdriver.

    mix phx.phantom
  """

  @doc false
  def run(_) do
    case where("#{System.cwd()}/#{@assets}/#{@phantomjs}") do
      {:ok, phantomjs} -> System.cmd(phantomjs, ["--wd"])
      {:error, phantomjs} -> Mix.shell().error("#{phantomjs} not found.")
    end
  end

  defp where(file) do
    with {path, 0} <- System.cmd("ls", [file]),
         true <- Regex.match?(~r/#{file}/, String.trim(path)) do
      {:ok, String.trim(path)}
    else
      false -> {:error, file}
    end
  end
end
