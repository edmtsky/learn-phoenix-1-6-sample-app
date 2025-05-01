defmodule SampleAppWeb.UserSignupTest do
  use SampleAppWeb.ConnCase, async: true
  alias SampleAppWeb.Endpoint

  test "invalid signup information", %{conn: conn} do
    user_records_before = Repo.one(from u in User, select: count())

    conn =
      conn
      |> get(Routes.signup_path(conn, :new))
      |> post(Routes.signup_path(conn, :create), %{
        user: %{
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      })

    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before == user_records_after

    html_response(conn, 200)
    # CSS class for the error count tag
    |> assert_select("div.alert-danger")
    # CSS class for field with error explanation
    |> assert_select("span.invalid-feedback", count: 4)
    # make sure that `<form  action="/signup"` not `/users`(what was by default)
    |> assert_select("form[action='#{Routes.signup_path(Endpoint, :create)}']")
  end

  test "valid signup information", %{conn: conn} do
    user_email = "user@example.com"
    user_records_before = Repo.one(from u in User, select: count())

    conn =
      conn
      |> get(Routes.signup_path(conn, :new))
      |> post(Routes.signup_path(conn, :create), %{
        user: %{
          name: "Example User",
          email: user_email,
          password: "password",
          password_confirmation: "password"
        }
      })

    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before + 1 == user_records_after

    user = Repo.get_by(User, email: user_email)
    assert redirected_to(conn) == Routes.user_path(conn, :show, user)

    refute Enum.empty?(get_flash(conn))

    # jump by redirect to check out the flash message
    # check what profile page has welcome flash message with alert-success css class
    conn = get(conn, Routes.user_path(conn, :show, user))
    html_response(conn, 200)
    |> assert_select("div.alert-success")
  end
end
