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


### Pagination

adopt one of the simplest and most robust, called `scrivener_ecto`.
To use it, you need to include both
the `scrivener_ecto` package and `scrivener_html`,
scrivener_html configures `scrivener_ecto` to use Bootstrap's pagination styles.

- https://github.com/mojotech/scrivener
- https://github.com/mojotech/scrivener_ecto
- https://github.com/mgwidmann/scrivener_html


Related Libraries (from https://github.com/mojotech/scrivener)

- Scrivener.Ecto paginate your Ecto queries with Scrivener
- Scrivener.HTML generates HTML output using Bootstrap or other frameworks
- Scrivener.Headers adds response headers for API pagination
- Scrivener.List allows pagination of a list

mix.exs
```elixir
  defp deps do
    [
      # ...
      {:scrivener_ecto, "2.7.0"},                                           # +
      {:scrivener_html,                                                     # +
      git: "https://github.com/goravbhootra/scrivener_html",                # +
      ref: "4984551e8bdb609f49df59c5a93cdea59a1dfa84"}                      # +
    ]
  end
```

```sh
mix deps.get
```

```heex
<h1>All users</h1>

<%= pagination_links @conn, @users_page %>

<ul class="users">
  <%= for user <- @users_page do %>
    <li>
      <%= gravatar_for user, size: 50 %>
      <%= link user.name, to: Routes.user_path(@conn, :show, user) %>
    </li>
  <% end %>
</ul>

<%= pagination_links @conn, @users_page %>

```
- `@users_page` - is a `Scrivener.Page` struct
(then displays pagination links to access other pages)


```elixir
defmodule SampleAppWeb.UserView do
  use SampleAppWeb, :view
  use Scrivener.HTML                                                     # <<< +

  # ...
end
```

```elixir
defmodule SampleApp.Repo do
  use Ecto.Repo,
    otp_app: :sample_app,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 30                                          # <<< +
end
```


```elixir
iex> alias SampleApp.Repo
SampleApp.Repo

iex> alias SampleApp.Accounts.User
SampleApp.Accounts.User

iex> Repo.paginate(User, %{page: 1})
[debug] QUERY OK source="users" db=1.4ms decode=1.6ms queue=1.5ms idle=1397.8ms
SELECT count('*') FROM "users" AS u0 []
[debug] QUERY OK source="users" db=11.3ms queue=0.8ms idle=1429.9ms
SELECT u0."id", u0."email", u0."name", u0."password_hash", u0."inserted_at",
u0."updated_at" FROM "users" AS u0 LIMIT $1 OFFSET $2 [30, 0]
%Scrivener.Page{
  entries: [
    %SampleApp.Accounts.User{
      __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
      email: "examplephoenixtutorial@gmail.com",
      id: 1,
      inserted_at: ~N[2021-12-26 04:01:05],
      name: "Example User",
      password: nil,
      password_confirmation: nil,
      password_hash: "$argon2id$v=19$m=256,t=1,
      p=4$vBnGsJGO39uddO8mrXF/Xw$Rhme+XdMAp/FpG41jlUmZkMBV1Wc0pLsf+OuGgr+v7g",
      updated_at: ~N[2021-12-26 04:01:05]
    },
    .
    .
    .
  ],
  page_number: 1,
  page_size: 30,
  total_entries: 100,
  total_pages: 4
}
```


### Partial refactoring

```heex
<h1>All users</h1>

<%= pagination_links @conn, @users_page %>

<ul class="users">
  <%= for user <- @users_page do %>
    <%= render "_user.html", conn: @conn, user: user %>             <!-- << -->
  <% end %>
</ul>

<%= pagination_links @conn, @users_page %>
```

removed code:
```heex
    <li>
      <%= gravatar_for user, size: 50 %>
      <%= link user.name, to: Routes.user_path(@conn, :show, user) %>
    </li>
```


> lib/sample_app_web/templates/user/_user.html.heex
```heex
<li>
  <%= gravatar_for @user, size: 50 %>
  <%= link @user.name, to: Routes.user_path(@conn, :show, @user) %>
</li>
```



### Deleting users

#### Administrative users


```sh
mix ecto.gen.migration add_admin_to_users
```

```elixir
defmodule SampleApp.Repo.Migrations.AddAdminToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do                                                  # +
      add :admin, :boolean, null: false, default: false                     # +
    end                                                                     # +
  end
end
```


```sh
mix ecto.migrate

18:19:13.784 [info]  == Running 20250504151816 SampleApp.Repo.Migrations.AddAdminToUsers.change/0 forward

18:19:13.804 [info]  alter table users

18:19:13.833 [info]  == Migrated 20250504151816 in 0.0s
```

make a first user admin

```sh
iex -S mix
```

```elixir
iex> user = SampleApp.Accounts.get_user(1)
# ...
iex> {:ok, user} = Ecto.Changeset.change(user, %{admin: true})
     |> SampleApp.Repo.update()
# ...
iex> user.admin
true
```


> priv/repo/seeds.exs
```elixir
SampleApp.Repo.insert!(%SampleApp.Accounts.User{
  name: "Example User",
  email: "examplephoenixtutorial@gmail.com",
  password_hash: Argon2.hash_pwd_salt("foobar"),
  admin: true                                                               # +
})
# ...
```


#### Revisiting cast parameters
not allow the admin attribute to be edited via the web.

```sh
put /users/17?admin=1
```

allow only update fields that are safe to edit through the web.
This can be accomplished by using the `cast` function in our `update_changeset`
and `changeset` function:

```elixir
user
|> cast(attrs, [
  :name,
  :email,
  :password,
  :password_confirmation
])
```

Note that `admin` is not in the list of permitted parameters.
This is what
prevents arbitrary users from granting themselves administrative access to app.


```elixir
defmodule SampleAppWeb.UserControllerTest do
  # ...

  test "should not allow the admin attribute to be edited via the web",
       %{conn: conn, other_user: other_user} do
    conn = login_as(conn, other_user)
    assert other_user.admin == false

    put(
      conn,
      Routes.user_path(conn, :update, other_user, %{
        user: %{
          password: "",
          password_confirmation: "",
          admin: true,
        }
      })
    )

    updated_other_user = Accounts.get_user(other_user.id)
    assert updated_other_user.admin == false
  end
```

- Ecto.Changeset.cast from docs:
All parameters that are not explicitly permitted are ignored.


### The delete action

add delete links visible only for admins:

> lib/sample_app_web/templates/user/_user.html.heex
```heex
<li>
  <%= gravatar_for @user, size: 50 %>
  <%= link @user.name, to: Routes.user_path(@conn, :show, @user) %>
  <%= if @conn.assigns.current_user.admin && @conn.assigns.current_user
  != @user do %>
    | <%= link "delete",
            to: Routes.user_path(@conn, :delete, @user),
            method: :delete, data: [confirm: "You sure?"] %>
  <% end %>
</li>
```

Note:
Web browsers can't send `DELETE` requests natively, so
Phoenix fakes them with JavaScript.


Adding a working delete action:
```elixir
defmodule SampleAppWeb.UserController do
  # ...
  plug :logged_in_user when action in [:index, :edit, :update, :delete]
  #                                                             ^+++++

  # ...

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    Accounts.delete_user(user)

    conn
    |> put_flash(:success, "User deleted")
    |> redirect(to: Routes.user_path(conn, :index))
  end
```



Adding the AuthPlug.admin_user function:

```elixir
defmodule SampleAppWeb.AuthPlug do
  # ...

  # Function plug that confirms an admin user.
  def admin_user(conn, _opts) do
    unless conn.assigns.current_user.admin do
      conn
      |> redirect(to: Routes.root_path(conn, :home))
      |> halt()
    else
      conn
    end
  end
  # ...
end
```


Importing the `admin_user` function in the SampleAppWeb module:
```elixir
defmodule SampleAppWeb do
  # ...

  def controller do
    quote do
      use Phoenix.Controller, namespace: SampleAppWeb
      # ...

      import SampleAppWeb.AuthPlug,                                         # +
        only: [logged_in_user: 2, correct_user: 2, admin_user: 2]           # +

      # ...
    end
  end
  # ...
end
```


Adding the `AuthPlug.admin_user` restricting the `delete` action to admins:
```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  plug :logged_in_user when action in [:index, :edit, :update, :delete]
  plug :correct_user   when action in [:edit, :update]
  plug :admin_user     when action in [:delete]                             # +
  #...
end
```


in logs:
```elixir
[info] POST /users/4
[debug] Processing with SampleAppWeb.UserController.delete/2
  Parameters: %{"_csrf_token" => "YSA...", "_method" => "delete", "id" => "4"}
  Pipelines: [:browser]
[debug] QUERY OK source="users" db=0.3ms idle=1356.1ms
SELECT u0."id", u0."email", u0."name", u0."password_hash", u0."admin", u0."inserted_at", u0."updated_at" FROM "users" AS u0 WHERE (u0."id" = $1) [1]
[debug] QUERY OK source="users" db=1.5ms idle=1356.7ms
SELECT u0."id", u0."email", u0."name", u0."password_hash", u0."admin", u0."inserted_at", u0."updated_at" FROM "users" AS u0 WHERE (u0."id" = $1) [4]
[debug] QUERY OK db=27.8ms queue=1.1ms idle=1374.5ms
DELETE FROM "users" WHERE "id" = $1 [4]
```


### learned:

- Users can be updated using an `edit` form,
  which sends a `PUT` request to the update action.
- Safe updating through the web is enforced using the `cast` function
  provided by the `ecto` package (Ecto.Changeset.cast).
- Plugs give a standard way to run functions that
  manipulate the `conn` before particular controller actions.
- We implement authorization using function plugs.
- Authorization tests use low-level commands
  to submit particular HTTP requests directly to controller actions.
- Friendly forwarding redirects users where they wanted to go after logging in.
- The users index page shows all users, one page at a time.
- Phoenix uses the standard file `priv/repo/seeds.exs` to seed the database
  with sample data using `mix run priv/repo/seeds.exs`.
- Using `render_many @users_page, SampleAppWeb.UserView "_user.html", assigns`
  calls the `_user.html.heex` partial on each
  user in the `@users_page` list assign.
- Admins can delete users through the web
  by clicking on delete links
  that issue DELETE requests to the User controller delete action.
- We can create a large number of test users using `ExMachina` and
  our `User` factory.

