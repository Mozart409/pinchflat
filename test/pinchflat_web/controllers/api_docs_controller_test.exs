defmodule PinchflatWeb.ApiDocsControllerTest do
  use PinchflatWeb.ConnCase

  describe "index/2" do
    test "returns Scalar UI HTML page", %{conn: conn} do
      conn = get(conn, "/api/docs")

      assert html_response(conn, 200) =~ "Pinchflat API Documentation"
      assert html_response(conn, 200) =~ "@scalar/api-reference"
      assert html_response(conn, 200) =~ "/api/spec"
    end
  end
end
