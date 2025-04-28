defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end
end
