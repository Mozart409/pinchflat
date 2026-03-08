defmodule PinchflatWeb.ApiSpecController do
  @moduledoc """
  Controller for serving the OpenAPI specification.
  """

  use PinchflatWeb, :controller

  def spec(conn, _params) do
    spec =
      PinchflatWeb.ApiSpec.spec()
      |> OpenApiSpex.OpenApi.to_map()

    conn
    |> put_status(:ok)
    |> put_resp_header("content-type", "application/json")
    |> json(spec)
  end
end
