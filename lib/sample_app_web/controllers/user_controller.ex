defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user, title: user.name)
  end

  # to handle signup form submition via POST /users
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> redirect(to: Routes.user_path(conn, :show, user))

      # Handle a successful User insertion.
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
