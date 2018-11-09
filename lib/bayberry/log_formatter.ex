defmodule Bayberry.LogFormatter do

  def format(level, message, timestamp, metadata) do
    ~s([#{iso8601(timestamp)}] #{request_id(metadata)} [#{level}] #{message}\n)
  rescue
    _ -> "Cannot format message\n"
  end

  defp iso8601({date, {hh, mm, ss, _ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}),
         result <- NaiveDateTime.to_iso8601(timestamp) do
      "#{result}+00:00"
    end
  end

  defp request_id(metadata) do
    case metadata[:request_id] do
      nil -> nil
      request_id -> "request_id=#{request_id}"
    end
  end
end
