update users

URL for a user's edit page(update profile) is `/users/1/edit` (See Table_7_1)
UserController.edit action

- add SampleAppWeb.UserController.edit action for (/users/1/edit)
- add title for DynamicTextHelper ("Edit profile")
- add lib/sample_app_web/templates/user/edit.html.heex
  (with using error_count_tag)
- update Settings link in lib/sample_app_web/templates/layout/_header.html.heex
  (add link in drop menu Accout -> Settings)

```heex
    <%= link "Settings",
      to: Routes.user_path(@conn, :edit, @current_user),
      class: "dropdown-item" %>
```

```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  # ...

  # action to send edit-form    <- Routes.user_path(@conn, :edit, @current_user)
  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  # to handle PUT /users/:id/edit from edit-form
  def update(conn, _params) do
    html(conn, "TODO")
  end
end
```


### target="_blank" + rel="noopener" for Gravatar

to fix a minor security issue associated with
using `target="_blank"` to open URLs, which is that
the target site gains control of what's known as the "window object"
associated with the HTML document.
The target site could potentially introduce malicious content,
such as a phishing page.

to eliminate this risk entirely - add `rel="noopener"` to the origin link.

```html
<a href="http://example.com" target="_blank" rel="noopener">
    some link
</a>
```

https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/rel/noopener


### Handle successful edit("Update your profile")

In order to provide users the ability to update their profile without entering a
password and password confirmation, you need to create additional changeset func:

create a new changeset function named `update_changeset` and
create a custom validates function named `validate_blank`

```elixir
defmodule SampleApp.Accounts do
  # ...

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)       # << to allow update without password
    |> Repo.update()
  end
```

```elixir
defmodule SampleApp.Accounts.User do
  # ...

  # when editing a user, we want users to be able to update their profile
  # without entering a password and password confirmation for convenience.
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :password,
      :password_confirmation
    ])
    |> validate_required([:name, :email])
    |> validate_blank([:password, :password_confirmation])
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, message: "does not match password")
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  # to validate for presence only on non-nil fields in User schema
  defp validate_blank(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      if get_change(changeset, field) == nil do
        changeset
      else
        validate_required(changeset, field)
      end
    end)
  end
```


### Authorization


#### Requiring logged-in users

Block attempt to edit users who have not logged-in.

requiring users to be logged-in when editing their profiles.
- add `AuthPlug.logged_in_user` - a plug function

```elixir
defmodule SampleAppWeb.AuthPlug do
  # ...
  import Phoenix.Controller                                                 # +
  alias SampleAppWeb.Router.Helpers, as: Routes                             # +

  # ...

  # function plug that confirms a logged-in user                            # +
  def logged_in_user(conn, _opts) do                                        # +
    if conn.assigns.current_user do                                         # +
      conn                                                                  # +
    else                                                                    # +
      conn                                                                  # +
      |> put_flash(:danger, "please log in.")                               # +
      |> redirect(to: Routes.login_path(conn, :create))                     # +
      |> halt()                                                             # +
    end                                                                     # +
  end                                                                       # +

  #...
end
```


- import the `AuthPlug.logged_in_user` function in `SampleAppWeb` module
  (so you can use it in all controllers)

- use AuthPlug.logged_in_user in UserController only for edit and update actions:


```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  plug :logged_in_user when action in [:edit, :update]                     # +
  # ...

end
```


#### Requiring the right user

Users should only be allowed to edit their own information.
(protect the `edit` and `update` actions)

```elixir
defmodule SampleAppWeb do
  # ...
  def controller do
    quote do
      # ...
      import SampleAppWeb.AuthPlug, only: [logged_in_user: 2, correct_user: 2]
      # ...                                                   ^^^^^^^^^^^^
    end
  end
  #  ...
```

```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  plug :logged_in_user when action in [:edit, :update]
  plug :correct_user   when action in [:edit, :update]                      # +
  # ...
```

```elixir
defmodule SampleAppWeb.AuthPlug do
  # ...

  # Function plug that confirms the correct user.
  def correct_user(conn, _opts) do                                          # +
    user_id = String.to_integer(conn.params["id"])                          # +

    unless user_id == conn.assigns.current_user.id do                       # +
      conn                                                                  # +
      |> redirect(to: Routes.root_path(conn, :home))                        # +
      |> halt()                                                             # +
    else                                                                    # +
      conn                                                                  # +
    end                                                                     # +
  end                                                                       # +
  # ...
end
```


### Friendly forwarding

This is about remembering where the user who did not logged-in wanted to enter
and, after his login, to redirect him to that place.

```elixir
 def create(conn, %{
        "session" => %{
          "email" => email,
          "password" => pass,
          "remember_me" => remember_me
        }
      }) do
    case Accounts.authenticate_by_email_and_pass(String.downcase(email), pass) do
      {:ok, user} ->
        conn = AuthPlug.login(conn, user)

        conn =
          if String.to_atom(remember_me) do
            AuthPlug.remember(conn, user)
          else
            delete_resp_cookie(conn, "remember_token")
          end

        conn
        |> put_flash(:success, "Welcome to the Sample App!")
        |> AuthPlug.redirect_back_or(Routes.user_path(conn, :show, user)) # +
        # |> redirect(to: Routes.user_path(conn, :show, user))            # -

      {:error, _reason} ->
       # ...
    end
  end
```

add integration test
```elixir
defmodule SampleAppWeb.UserEditTest do
  #...

  test "successful edit with friendly forwarding", %{conn: conn, user: user} do
    # ...
    # - 1. tries to visit the `edit` page,
    # - 2. then logs-in,
    # - 3. and then checks that the user is redirected to the `edit` page
    #      instead of the default profile page(/users/123).
  end
end
```

In order to forward users to their intended destination,
you need to store the location of the requested page somewhere,
and then redirect to that location instead of to the default.

- `AuthPlug.store_location`
- `AuthPlug.redirect_back_or`

based on:
```elixir
path = get_session(conn, :forwarding_url) || default
delete_session(:forwarding_url)
redirect(to: path)

put_session(conn, :forwarding_url, conn.request_path)
```

to filter only GET-requests:

```elixir
case conn do
  %Plug.Conn{method: "GET"} ->
    put_session(conn, :forwarding_url, conn.request_path)
  _ -> conn
end
```
add `AuthPlug.store_location` into  `AuthPlug.logged_in_user`

and `AuthPlug.redirect_back_or(conn, Routes.user_path(conn, :show, user))`
to `SessionController.create/2`



### Showing all users

#### Users Index
first implement a security model:
- the list of all users is available only to logged-in users.
  (protect the `index` page from unauthorized access)

```elixir
defmodule SampleAppWeb.UserControllerTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    {:ok, user: Factory.insert(:user), other_user: Factory.insert(:user)}
  end

  test "should redirect index when not logged in", %{conn: conn} do         # +
    conn = get(conn, Routes.user_path(conn, :index))                        # +

    refute Enum.empty?(get_flash(conn))                                     # +
    assert redirected_to(conn, 302) == Routes.login_path(conn, :create)     # +
  end                                                                       # +

  #...
end
```

add an `index` action with pretection by `AuthPlug.logged_in_user`

```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  #                                    v+++++
  plug :logged_in_user when action in [:index, :edit, :update]              # +
  plug :correct_user   when action in [:edit, :update]

  def index(conn, _params) do                                               # +
    users = Accounts.list_users()                                           # +
    render(conn, "index.html", users: users)                                # +
  end                                                                       # +

  # ...
end
```

> lib/sample_app_web/templates/user/index.html.heex
```heex
<h1>All users</h1>

<ul class="users">
  <%= for user <- @users do %>
    <li>
      <%= gravatar_for user, size: 50 %>
      <%= link user.name, to: Routes.user_path(@conn, :show, user) %>
    </li>
  <% end %>
</ul>
```

DynamicTextHelper:

```elixir
 defp get_page_title(%{view_module: UserView, action: :index}), do: "All users"
```

css style, update link in _header

add an integration test for all the layout links,
(including the proper behavior for logged-in and non-logged-in users)



### Sample users

using faker package (add to mix.exs and mix deps.get)

priv/repo/seeds.exs
```elixir
SampleApp.Repo.insert!(%SampleApp.Accounts.User{
  name: "Example User",
  email: "example@gmail.com",
  password_hash: Argon2.hash_pwd_salt("foobar")
})

for n <- 1..99 do
  SampleApp.Repo.insert!(%SampleApp.Accounts.User{
    name: Faker.Person.name(),
    email: "example-#{n}@example.com",
    password_hash: Argon2.hash_pwd_salt("foobar")
  })
end
```

```sh
mix ecto.reset
```
or
```sh
mix run priv/repo/seeds.exs
```
