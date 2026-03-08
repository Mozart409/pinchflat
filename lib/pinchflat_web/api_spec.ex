defmodule PinchflatWeb.ApiSpec do
  @moduledoc """
  OpenAPI 3.0 specification for the Pinchflat API.
  """

  alias OpenApiSpex.{Info, MediaType, OpenApi, Parameter, PathItem, Response, Server}

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
        "/healthcheck" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "HealthController.check",
            summary: "Health check",
            description: "Returns the health status of the application",
            tags: ["System"],
            responses: %{
              "200" => %Response{
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
        "/api/spec" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "ApiSpecController.spec",
            summary: "OpenAPI specification",
            description: "Returns the OpenAPI 3.0 specification document for this API",
            tags: ["System"],
            responses: %{
              "200" => %Response{
                description: "OpenAPI specification JSON",
                content: %{
                  "application/json" => %MediaType{
                    schema: %OpenApiSpex.Schema{
                      type: :object,
                      description: "OpenAPI 3.0 specification"
                    }
                  }
                }
              }
            }
          }
        },
        "/api/media/recent_downloads" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.MediaController.recent_downloads",
            summary: "Recent downloads",
            description: "Returns a list of recently downloaded media items",
            tags: ["Media"],
            parameters: [
              %Parameter{
                name: :limit,
                in: :query,
                description: "Maximum number of results to return (1-500)",
                schema: %OpenApiSpex.Schema{type: :integer, minimum: 1, maximum: 500, default: 50}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Success",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.RecentDownloadsResponse
                  }
                }
              }
            }
          }
        },
        "/sources" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.index",
            summary: "List sources",
            description: "Returns a list of all sources",
            tags: ["Sources"],
            responses: %{
              "200" => %Response{
                description: "List of sources",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.SourcesListResponse
                  }
                }
              }
            }
          },
          post: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.create",
            summary: "Create source",
            description: "Creates a new source from a YouTube channel or playlist URL",
            tags: ["Sources"],
            requestBody: %OpenApiSpex.RequestBody{
              description: "Source creation parameters",
              required: true,
              content: %{
                "application/json" => %MediaType{
                  schema: PinchflatWeb.Schemas.CreateSourceRequest
                }
              }
            },
            responses: %{
              "201" => %Response{
                description: "Source created successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.Source
                  }
                }
              },
              "422" => %Response{
                description: "Validation error"
              }
            }
          }
        },
        "/sources/{id}" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.show",
            summary: "Get source",
            description: "Returns details for a specific source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Source details",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.Source
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          },
          put: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.update",
            summary: "Update source",
            description: "Updates an existing source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            requestBody: %OpenApiSpex.RequestBody{
              description: "Source update parameters",
              required: true,
              content: %{
                "application/json" => %MediaType{
                  schema: PinchflatWeb.Schemas.UpdateSourceRequest
                }
              }
            },
            responses: %{
              "200" => %Response{
                description: "Source updated successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.Source
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              },
              "422" => %Response{
                description: "Validation error"
              }
            }
          },
          delete: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.delete",
            summary: "Delete source",
            description: "Deletes a source and optionally its associated media files",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              },
              %Parameter{
                name: :delete_files,
                in: :query,
                description: "Also delete associated media files from disk",
                schema: %OpenApiSpex.Schema{type: :boolean, default: false}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Source deletion started",
                content: %{
                  "application/json" => %MediaType{
                    schema: %OpenApiSpex.Schema{
                      type: :object,
                      properties: %{
                        message: %OpenApiSpex.Schema{type: :string}
                      }
                    }
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/sources/opml" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.opml_feed",
            summary: "OPML feed",
            description:
              "Returns an OPML feed containing all sources as podcast feeds. Useful for importing into podcast clients.",
            tags: ["Podcasts"],
            responses: %{
              "200" => %Response{
                description: "OPML XML feed",
                content: %{
                  "application/opml+xml" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, description: "OPML XML document"}
                  }
                }
              }
            }
          }
        },
        "/sources/{uuid}/feed" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.rss_feed",
            summary: "RSS feed for source",
            description:
              "Returns an RSS podcast feed for a specific source. Contains up to 2000 most recent media items.",
            tags: ["Podcasts"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Source UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "RSS XML feed",
                content: %{
                  "application/rss+xml" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, description: "RSS XML document"}
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/sources/{uuid}/feed_image" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.feed_image",
            summary: "Source feed image",
            description: "Returns the cover image for a source's podcast feed",
            tags: ["Podcasts"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Source UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Image file",
                content: %{
                  "image/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Image file data"}
                  }
                }
              },
              "404" => %Response{
                description: "Image not found"
              }
            }
          }
        },
        "/media/{uuid}/episode_image" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.episode_image",
            summary: "Episode thumbnail",
            description: "Returns the thumbnail image for a specific media item",
            tags: ["Podcasts"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Media item UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Image file",
                content: %{
                  "image/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Image file data"}
                  }
                }
              },
              "404" => %Response{
                description: "Image not found"
              }
            }
          }
        },
        "/media/{uuid}/stream" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "MediaItems.MediaItemController.stream",
            summary: "Stream media file",
            description: """
            Streams a media file with HTTP Range request support for seeking.
            Supports partial content delivery (206) for efficient streaming.
            """,
            tags: ["Podcasts"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Media item UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              },
              %Parameter{
                name: :range,
                in: :header,
                description: "Byte range for partial content (e.g., 'bytes=0-1023')",
                schema: %OpenApiSpex.Schema{type: :string, example: "bytes=0-1023"}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Full media file",
                content: %{
                  "video/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Media file data"}
                  },
                  "audio/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Media file data"}
                  }
                }
              },
              "206" => %Response{
                description: "Partial content (for range requests)",
                content: %{
                  "video/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Partial media file data"}
                  },
                  "audio/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Partial media file data"}
                  }
                }
              },
              "404" => %Response{
                description: "Media file not found"
              }
            }
          }
        },
        "/api/media_profiles" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.MediaProfileController.index",
            summary: "List media profiles",
            description: "Returns a list of all media profiles",
            tags: ["MediaProfiles"],
            responses: %{
              "200" => %Response{
                description: "List of media profiles",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.MediaProfilesListResponse
                  }
                }
              }
            }
          },
          post: %OpenApiSpex.Operation{
            operationId: "Api.MediaProfileController.create",
            summary: "Create media profile",
            description: "Creates a new media profile",
            tags: ["MediaProfiles"],
            requestBody: %OpenApiSpex.RequestBody{
              description: "Media profile creation parameters",
              required: true,
              content: %{
                "application/json" => %MediaType{
                  schema: PinchflatWeb.Schemas.CreateMediaProfileRequest
                }
              }
            },
            responses: %{
              "201" => %Response{
                description: "Media profile created successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.MediaProfile
                  }
                }
              },
              "422" => %Response{
                description: "Validation error"
              }
            }
          }
        },
        "/api/media_profiles/{id}" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.MediaProfileController.show",
            summary: "Get media profile",
            description: "Returns details for a specific media profile",
            tags: ["MediaProfiles"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Media profile ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Media profile details",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.MediaProfile
                  }
                }
              },
              "404" => %Response{
                description: "Media profile not found"
              }
            }
          },
          put: %OpenApiSpex.Operation{
            operationId: "Api.MediaProfileController.update",
            summary: "Update media profile",
            description: "Updates an existing media profile",
            tags: ["MediaProfiles"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Media profile ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            requestBody: %OpenApiSpex.RequestBody{
              description: "Media profile update parameters",
              required: true,
              content: %{
                "application/json" => %MediaType{
                  schema: PinchflatWeb.Schemas.UpdateMediaProfileRequest
                }
              }
            },
            responses: %{
              "200" => %Response{
                description: "Media profile updated successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.MediaProfile
                  }
                }
              },
              "404" => %Response{
                description: "Media profile not found"
              },
              "422" => %Response{
                description: "Validation error"
              }
            }
          },
          delete: %OpenApiSpex.Operation{
            operationId: "Api.MediaProfileController.delete",
            summary: "Delete media profile",
            description: "Deletes a media profile and optionally its associated sources and media files",
            tags: ["MediaProfiles"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Media profile ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              },
              %Parameter{
                name: :delete_files,
                in: :query,
                description: "Also delete associated media files from disk",
                schema: %OpenApiSpex.Schema{type: :boolean, default: false}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Media profile deletion started",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Media profile not found"
              }
            }
          }
        },
        "/api/media" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.MediaController.index",
            summary: "List media items",
            description: "Returns a list of media items with optional filtering",
            tags: ["Media"],
            parameters: [
              %Parameter{
                name: :source_id,
                in: :query,
                description: "Filter by source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              },
              %Parameter{
                name: :limit,
                in: :query,
                description: "Maximum number of results to return (1-500)",
                schema: %OpenApiSpex.Schema{type: :integer, minimum: 1, maximum: 500, default: 50}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "List of media items",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.MediaItemsListResponse
                  }
                }
              }
            }
          }
        },
        "/api/media/{id}" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.MediaController.show",
            summary: "Get media item",
            description: "Returns details for a specific media item",
            tags: ["Media"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Media item ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Media item details",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.MediaItem
                  }
                }
              },
              "404" => %Response{
                description: "Media item not found"
              }
            }
          },
          delete: %OpenApiSpex.Operation{
            operationId: "Api.MediaController.delete",
            summary: "Delete media item files",
            description: "Deletes the media files associated with a media item",
            tags: ["Media"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Media item ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              },
              %Parameter{
                name: :prevent_download,
                in: :query,
                description: "Prevent future re-download of this media item",
                schema: %OpenApiSpex.Schema{type: :boolean, default: false}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Media files deleted successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Media item not found"
              }
            }
          }
        },
        "/api/media/{id}/actions/download" => %PathItem{
          post: %OpenApiSpex.Operation{
            operationId: "Api.MediaController.download",
            summary: "Force download media item",
            description: "Triggers a download job for the specified media item",
            tags: ["Media"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Media item ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Download job created",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Media item not found"
              }
            }
          }
        },
        "/api/search" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.SearchController.search",
            summary: "Search media items",
            description: "Search for media items by title",
            tags: ["Search"],
            parameters: [
              %Parameter{
                name: :q,
                in: :query,
                required: true,
                description: "Search query",
                schema: %OpenApiSpex.Schema{type: :string, example: "my video"}
              },
              %Parameter{
                name: :limit,
                in: :query,
                description: "Maximum number of results",
                schema: %OpenApiSpex.Schema{type: :integer, minimum: 1, maximum: 500, default: 50}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Search results",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.SearchResponse
                  }
                }
              }
            }
          }
        },
        "/api/sources/{id}/actions/download_pending" => %PathItem{
          post: %OpenApiSpex.Operation{
            operationId: "Api.SourceActionsController.download_pending",
            summary: "Download pending media",
            description: "Triggers download jobs for all pending media items in this source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Download jobs created",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/api/sources/{id}/actions/redownload" => %PathItem{
          post: %OpenApiSpex.Operation{
            operationId: "Api.SourceActionsController.redownload",
            summary: "Re-download all media",
            description: "Triggers re-download jobs for all existing media items in this source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Re-download jobs created",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/api/sources/{id}/actions/index" => %PathItem{
          post: %OpenApiSpex.Operation{
            operationId: "Api.SourceActionsController.index",
            summary: "Force index source",
            description: "Triggers an indexing job to fetch the latest media from this source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Index job created",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/api/sources/{id}/actions/refresh_metadata" => %PathItem{
          post: %OpenApiSpex.Operation{
            operationId: "Api.SourceActionsController.refresh_metadata",
            summary: "Refresh source metadata",
            description: "Triggers a job to refresh metadata for this source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Metadata refresh job created",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/api/sources/{id}/actions/sync_files" => %PathItem{
          post: %OpenApiSpex.Operation{
            operationId: "Api.SourceActionsController.sync_files",
            summary: "Sync files to disk",
            description: "Triggers a job to sync database records with actual files on disk",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "File sync job created",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/api/tasks" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.TaskController.index",
            summary: "List tasks",
            description: "Returns a list of background tasks with optional filtering",
            tags: ["Tasks"],
            parameters: [
              %Parameter{
                name: :source_id,
                in: :query,
                description: "Filter by source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              },
              %Parameter{
                name: :media_item_id,
                in: :query,
                description: "Filter by media item ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              },
              %Parameter{
                name: :worker,
                in: :query,
                description: "Filter by worker name (e.g., 'MediaDownloadWorker')",
                schema: %OpenApiSpex.Schema{type: :string}
              },
              %Parameter{
                name: :state,
                in: :query,
                description: "Filter by job state",
                schema: %OpenApiSpex.Schema{
                  type: :string,
                  enum: [:available, :scheduled, :executing, :retryable, :completed, :discarded, :cancelled]
                }
              }
            ],
            responses: %{
              "200" => %Response{
                description: "List of tasks",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.TasksListResponse
                  }
                }
              }
            }
          }
        },
        "/api/tasks/{id}" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.TaskController.show",
            summary: "Get task",
            description: "Returns details for a specific task",
            tags: ["Tasks"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Task ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Task details",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.Task
                  }
                }
              },
              "404" => %Response{
                description: "Task not found"
              }
            }
          },
          delete: %OpenApiSpex.Operation{
            operationId: "Api.TaskController.delete",
            summary: "Cancel task",
            description: "Cancels and deletes a task",
            tags: ["Tasks"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Task ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Task cancelled successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.ActionResponse
                  }
                }
              },
              "404" => %Response{
                description: "Task not found"
              }
            }
          }
        },
        "/api/stats" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.StatsController.index",
            summary: "Get statistics",
            description: "Returns application statistics",
            tags: ["Statistics"],
            responses: %{
              "200" => %Response{
                description: "Application statistics",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.StatsResponse
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
