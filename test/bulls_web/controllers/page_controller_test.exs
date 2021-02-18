defmodule BullsWeb.PageControllerTest do
  use BullsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "React component loading..."
  end
end
