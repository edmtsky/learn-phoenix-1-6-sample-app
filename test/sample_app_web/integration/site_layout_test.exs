defmodule SampleAppWeb.SiteLayoutTest do
  use SampleAppWeb.ConnCase, async: true

  alias SampleAppWeb.DynamicTextHelpers
  alias SampleAppWeb.StaticPageView
  alias SampleAppWeb.UserView

  # A test for the links on the layout
  # This ensures that links to the pages are present.
  test "layout links", %{conn: conn} do
    conn = get(conn, Routes.root_path(conn, :home))

    assert Routes.root_path(conn, :home) == "/"
    assert Routes.help_path(conn, :help) == "/help"

    html_response(conn, 200)
    |> assert_select("a[href='#{Routes.root_path(conn, :home)}']", count: 2)
    |> assert_select("a[href='#{Routes.help_path(conn, :help)}']")
    |> assert_select("a[href='#{Routes.about_path(conn, :about)}']")
    |> assert_select("a[href='#{Routes.contact_path(conn, :contact)}']")
  end

  test "contact page title", %{conn: conn} do
    # given
    contact_page_title =
      Enum.into(conn.assigns, %{view_module: StaticPageView, action: :contact})
      |> DynamicTextHelpers.page_title()
      |> to_string()

    # when
    conn = get(conn, Routes.contact_path(conn, :contact))

    # then
    html_response(conn, 200)
    |> assert_select("title", contact_page_title)
  end

  test "signup page title", %{conn: conn} do
    signup_page_title =
      Enum.into(conn.assigns, %{view_module: UserView, action: :new})
      |> DynamicTextHelpers.page_title()
      |> to_string()

    conn = get(conn, Routes.signup_path(conn, :new))

    html_response(conn, 200)
    |> assert_select("title", signup_page_title)
  end
end
