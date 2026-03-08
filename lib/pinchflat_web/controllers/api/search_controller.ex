defmodule PinchflatWeb.Api.SearchController do
  use PinchflatWeb, :controller

  alias Pinchflat.Media

  @default_limit 50

  def search(conn, params) do
    search_term = Map.get(params, "q", "")
    limit = parse_int(Map.get(params, "limit", "#{@default_limit}"), @default_limit)

    search_results = Media.search(search_term, limit: limit)

    conn
    |> put_status(:ok)
    |> json(%{data: search_results, query: search_term})
  end

  defp parse_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  defp parse_int(value, _default) when is_integer(value), do: value
  defp parse_int(_, default), do: default
end
