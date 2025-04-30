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
end
