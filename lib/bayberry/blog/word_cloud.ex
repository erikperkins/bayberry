defmodule Bayberry.WordCloud do
  alias Bayberry.Blog

  def word_count do
    Blog.list_articles()
    |> Enum.map(fn article -> article.body end)
    |> Enum.join(" ")
    |> String.replace(~r/(^|[\s]+)[^\w]+/, " ")
    |> String.replace(~r/[^\w]+([\s]+|$)/, " ")
    |> String.downcase()
    |> String.split(" ")
    |> remove_stopwords()
    |> Enum.reduce(%{}, &tally(&1, &2))
    |> Enum.map(fn {k, v} -> %{"text" => k, "size" => v} end)
    |> Enum.sort_by(fn count -> count["size"] end, &>=/2)
    |> Enum.take(35)
  end

  defp remove_stopwords(words) do
    stopwords =
      ~w(a about above after again against all am an and any are as at be
      because been before being below between both but by can could did do
      does doing down during each few for from further had has have having he
      her here hers herself him himself his how I if in into is it its itself
      let me more most my myself nor not of on once only or other ought our ours
      ourselves out over own same shall she should so some such than that the
      their them themselves then there these they this those through to too
      under until up us very was we were what when where which while who whom
      why will with would you your yours yourself yourselves)

    for word <- words, word not in stopwords, do: word
  end

  defp tally(x, %{} = count) do
    Map.merge(count, %{x => 1}, fn _k, p, q -> p + q end)
  end
end
