defmodule SampleAppWeb.UserLoginTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    {:ok, user: Factory.insert(:user)}
  end

  test "login with valid information", %{conn: conn, user: user} do
    conn = login_as(conn, user)

    assert is_logged_in?(conn)

    assert redir_path =
             redirected_to(conn) ==
               Routes.user_path(conn, :show, user)

    conn = get(recycle(conn), redir_path)

    html_response(conn, 200)
    |> refute_select("a[href='#{Routes.login_path(conn, :new)}']")
    |> assert_select("a[href='#{Routes.logout_path(conn, :delete)}']")
    |> assert_select("a[href='#{Routes.user_path(conn, :show, user)}']")
  end

  test "login with invalid information", %{conn: conn} do
    conn = get(conn, Routes.login_path(conn, :new))

    html_response(conn, 200)
    |> assert_select("form[action='#{Routes.login_path(conn, :create)}']")

    conn = login_as(conn, %User{email: "", password: ""})

    html_response(conn, 200)
    |> assert_select("form[action='#{Routes.login_path(conn, :create)}']")

    # has error messages
    refute Enum.empty?(get_flash(conn))
    # assert get_flash(conn) == %{"danger" => "Invalid email/password combination"}

    conn = get(conn, Routes.root_path(conn, :home))
    assert Enum.empty?(get_flash(conn))
  end

  # singup, login, logout
  test "login with valid information followed by logout",
       %{conn: conn, user: user} do
    # signup + login
    conn = login_as(conn, user)

    assert is_logged_in?(conn)

    assert redir_path =
             redirected_to(conn) ==
               Routes.user_path(conn, :show, user)

    # redirect to profile page
    conn = get(recycle(conn), redir_path)

    html_response(conn, 200)
    # no log-in link
    |> refute_select("a[href='#{Routes.login_path(conn, :new)}']")
    # has logout link
    |> assert_select("a[href='#{Routes.logout_path(conn, :delete)}']")
    # has profile link
    |> assert_select("a[href='#{Routes.user_path(conn, :show, user)}']")

    # /logout
    conn = delete(conn, Routes.logout_path(conn, :delete))
    refute is_logged_in?(conn)

    # ensure redirect to root(home) page
    assert redir_path = redirected_to(conn) == Routes.root_path(conn, :home)
    conn = get(recycle(conn), redir_path)

    html_response(conn, 200)
    # has only log-in link, no profile and logout links
    |> assert_select("a[href='#{Routes.login_path(conn, :new)}']")
    |> refute_select("a[href='#{Routes.logout_path(conn, :delete)}']")
    |> refute_select("a[href='#{Routes.user_path(conn, :show, user)}']")
  end

  test "login with remembering", %{conn: conn, user: user} do
    conn = login_as(conn, user, remember_me: "1")
    assert conn.cookies["remember_token"] != nil
  end

  test "login without remembering", %{conn: conn, user: user} do
    # Log in to set the cookie.
    conn = login_as(conn, user, remember_me: "true")
    assert conn.cookies["remember_token"] != nil
    # Log in again and verify that the cookie is deleted.
    conn = login_as(conn, user, remember_me: "false")
    assert conn.cookies["remember_token"] == nil
  end
end
