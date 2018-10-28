defmodule Mix.Tasks.Phx.Brunch.Build do
  use Mix.Task
  @assets "assets"
  @brunch "node_modules/brunch/bin/brunch"

  @shortdoc "Precompile static assets with brunch"
  @recursive true

  @moduledoc """
  Compiles static assets.

    mix phx.brunch.build
  """

  @doc false
  def run(_) do
    with {:ok, node} <- which("node"),
         {:ok, _} <- where("#{@assets}/#{@brunch}") do
      System.cmd(node, [@brunch, "build", "--production"], cd: @assets)
      IO.puts("Precompiled assets.")
    else
      {:error, precompiler} -> Mix.shell().error("#{precompiler} not found.")
    end
  end

  defp which(cmd) do
    case System.cmd("which", [cmd]) do
      {path, 0} -> {:ok, String.trim(path)}
      {_, 1} -> {:error, System.get_env("PATH")}
    end
  end

  defp where(file) do
    with {path, 0} <- System.cmd("ls", [file]),
         true <- Regex.match?(~r/#{file}/, String.trim(path)) do
      {:ok, path}
    else
      false -> {:error, file}
    end
  end
end
