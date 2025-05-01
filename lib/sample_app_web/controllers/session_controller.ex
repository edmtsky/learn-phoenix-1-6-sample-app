defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => pass }}) do
    case Accounts.authenticate_by_email_and_pass(String.downcase(email), pass) do
      {:ok, _user} ->
        conn

      # Log the user in and redirect to the user's show page.
      {:error, _reason} ->
        conn
        # Create an error message.
        |> put_flash(:danger, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(_conn, _params) do
  end
end
