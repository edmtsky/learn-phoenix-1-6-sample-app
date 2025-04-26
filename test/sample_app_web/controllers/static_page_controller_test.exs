# 26-04-2025 @author Edmtsky
defmodule SampleAppWeb.StaticPageControllerTest do
  use SampleAppWeb.ConnCase

  @base_title "Phoenix Tutorial Sample App"

  test "should get home", %{conn: conn} do
    conn = get(conn, Routes.static_page_path(conn, :home))

    html_response(conn, 200)
    |> assert_select("title", "Home | #{@base_title}")
  end

  test "should get help", %{conn: conn} do
    conn = get(conn, Routes.static_page_path(conn, :help))

    html_response(conn, 200)
    |> assert_select("title", "Help | #{@base_title}")
  end

  test "should get about", %{conn: conn} do
    conn = get(conn, Routes.static_page_path(conn, :about))

    html_response(conn, 200)
    |> assert_select("title", "About | #{@base_title}")
  end

  test "should get contact", %{conn: conn} do
    conn = get(conn, Routes.static_page_path(conn, :contact))

    html_response(conn, 200)
    |> assert_select("title", "Contact | #{@base_title}")
  end
end
