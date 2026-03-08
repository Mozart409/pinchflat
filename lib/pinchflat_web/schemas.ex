defmodule PinchflatWeb.Schemas do
  @moduledoc """
  OpenAPI schemas for the Pinchflat API.
  """

  alias OpenApiSpex.Schema

  defmodule HealthResponse do
    @moduledoc """
    Schema for health check response.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "HealthResponse",
      description: "Health check response",
      type: :object,
      properties: %{
        status: %Schema{type: :string, description: "Health status", example: "ok"}
      },
      required: [:status]
    })
  end

  defmodule MediaItem do
    @moduledoc """
    Schema for a media item.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "MediaItem",
      description: "A media item that has been downloaded",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Internal database ID", example: 1},
        uuid: %Schema{type: :string, description: "Unique identifier", example: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"},
        title: %Schema{type: :string, description: "Media title", example: "My Video Title"},
        media_id: %Schema{type: :string, description: "External media ID", example: "youtube_video_id"},
        source_id: %Schema{type: :integer, description: "ID of the source this media belongs to", example: 1},
        uploaded_at: %Schema{
          type: :string,
          format: :date_time,
          description: "When the media was originally uploaded",
          example: "2024-01-01T12:00:00Z"
        },
        media_downloaded_at: %Schema{
          type: :string,
          format: :date_time,
          description: "When the media was downloaded",
          example: "2024-01-02T10:30:00Z"
        },
        media_filepath: %Schema{
          type: :string,
          description: "Path to the downloaded media file",
          example: "/downloads/video.mp4"
        },
        thumbnail_filepath: %Schema{
          type: :string,
          description: "Path to the thumbnail file",
          example: "/downloads/thumbnail.jpg"
        },
        metadata_filepath: %Schema{
          type: :string,
          description: "Path to the metadata file",
          example: "/downloads/metadata.json"
        },
        nfo_filepath: %Schema{
          type: :string,
          description: "Path to the NFO file",
          example: "/downloads/video.nfo"
        },
        subtitle_filepaths: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Paths to subtitle files",
          example: ["/downloads/subtitle_en.srt", "/downloads/subtitle_de.srt"]
        }
      },
      required: [:id, :uuid, :title, :media_id, :source_id]
    })
  end

  defmodule RecentDownloadsResponse do
    @moduledoc """
    Schema for recent downloads response.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RecentDownloadsResponse",
      description: "Response containing a list of recently downloaded media items",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: MediaItem,
          description: "List of recently downloaded media items"
        }
      },
      required: [:data]
    })
  end
end
