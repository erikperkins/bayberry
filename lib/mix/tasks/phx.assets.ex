defmodule Mix.Tasks.Phx.Assets do
  use Mix.Task
  alias Mix.Tasks.Phx.Brunch.Build
  alias Mix.Tasks.Phx.Digest

  @moduledoc """
  Builds and digests static assets

    mix phx.assets
  """

  @doc false
  def run(_) do
    Build.run([])
    Digest.run([])
  end
end
