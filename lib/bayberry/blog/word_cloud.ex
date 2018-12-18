defmodule Bayberry.WordCloud do
  import Application, only: [get_env: 2]
  alias Bayberry.Blog

  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def word_count do
    Blog.list_articles()
    |> Enum.map(fn article -> article.body end)
    |> Enum.join(" ")
    |> String.replace(~r/(^|[\s]+)[^\w]+/, " ")
    |> String.replace(~r/[^\w]+([\s]+|$)/, " ")
    |> String.downcase()
    |> String.split(" ")
    |> remove_stopwords()
    |> remove_html()
    |> Enum.reduce(%{}, &tally(&1, &2))
    |> Enum.map(fn {k, v} -> %{"text" => k, "size" => v} end)
    |> Enum.sort_by(fn count -> count["size"] end, &>=/2)
    |> Enum.take(35)
  end

  defp remove_stopwords(words) do
    stopwords = @redis.json("stopwords")
    for word <- words, word not in stopwords, do: word
  end

  defp remove_html(words) do
    html_tags = @redis.json("html_tags")
    for word <- words, word not in html_tags, do: word
  end

  defp tally(x, %{} = count) do
    Map.merge(count, %{x => 1}, fn _k, p, q -> p + q end)
  end
end
