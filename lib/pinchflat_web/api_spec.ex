defmodule PinchflatWeb.ApiSpec do
  @moduledoc """
  OpenAPI 3.0 specification for the Pinchflat API.
  """

  alias OpenApiSpex.{Info, OpenApi, MediaType, Server}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "Pinchflat API",
        version: "1.0.0",
        description: "API for accessing Pinchflat media management data"
      },
      servers: [
        %Server{
          url: "/",
          description: "Current server"
        }
      ],
      paths: %{
        "/healthcheck" => %OpenApiSpex.PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "HealthController.check",
            summary: "Health check",
            description: "Returns the health status of the application",
            responses: %{
              "200" => %OpenApiSpex.Response{
                description: "Success",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.HealthResponse
                  }
                }
              }
            }
          }
        },
        "/api/media/recent_downloads" => %OpenApiSpex.PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.MediaController.recent_downloads",
            summary: "Recent downloads",
            description: "Returns a list of recently downloaded media items",
            parameters: [
              %OpenApiSpex.Parameter{
                name: :limit,
                in: :query,
                description: "Maximum number of results to return (1-500)",
                schema: %OpenApiSpex.Schema{type: :integer, minimum: 1, maximum: 500, default: 50}
              }
            ],
            responses: %{
              "200" => %OpenApiSpex.Response{
                description: "Success",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.RecentDownloadsResponse
                  }
                }
              }
            }
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
