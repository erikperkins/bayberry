defmodule Bayberry.WordCloud do
  alias Bayberry.Blog

  def word_count do
    Blog.list_articles
    |> Enum.map(fn article -> article.body end)
    |> Enum.join(" ")
    |> String.replace(~r/[\s]+[^\w]+/, " ")
    |> String.replace(~r/[^\w]+[\s]+/, " ")
    |> String.downcase()
    |> String.split(" ")
    |> Enum.reduce(%{}, &tally(&1, &2))
    |> Enum.map(fn {k, v} -> %{"text" => k, "size" => v} end)
    |> Enum.sort_by(fn count -> count["size"] end, &>=/2)
    |> Enum.take(25)
  end

  defp tally(x, %{} = count) do
    Map.merge(count, %{x => 1}, fn _k, p, q -> p + q end)
  end
end
