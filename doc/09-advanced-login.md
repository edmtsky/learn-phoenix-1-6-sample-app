# Advanced Login

implementation of the "remember me" feature.
Remember token based on permanent cookies.


## Remember token

first step toward persistent sessions by generating a signed remember token
appropriate for creating permanent cookies.

plan for creating persistent sessions:

1. Create a signed token.
2. Place the token in the browser cookies with an expiration date far in the future.
3. Place the signed remember token in the browser cookies.
4. When presented with a cookie containing the signed remember token,
   verify the remember token cookie and
   extract the user_id to login.


example of how generating and verifying a token works.

```sh
iex -S mix
```
```elixir
iex> user_id = 1
1

iex> token = Phoenix.Token.sign(SampleAppWeb.Endpoint, "user salt", user_id)
"SFMyNTY.g2gDYQFuBgD0n5_LfQFiAAFRgA.7OOb1Pq_GHILjnfbqfaRtFs8Efm5G-T_batK_mvX7Ms"

iex> Phoenix.Token.verify(SampleAppWeb.Endpoint, "user salt", token, \
...> max_age: :infinity)
{:ok, 1}
```


## Login with remembering

before

```elixir
defmodule SampleAppWeb.AuthPlug do
  # ...

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end
  # ...
```

a way to add support to remember_token into AuthPlug.call/2 function:

```elixir
cond do
  conn.assigns[:current_user] ->
    conn

  user_id = get_session(conn, :user_id) ->
    assign(conn, :current_user, Accounts.get_user(user_id))

  token = conn.cookies["remember_token"] ->
    case SampleApp.Token.verify_remember_token(token) do
      {:ok, user_id} ->
        if user = Accounts.get_user(user_id) do
          login(conn, user)
        else
          logout(conn)
        end

      {:error, _reason} ->
        logout(conn)
    end

  true ->
    assign(conn, :current_user, nil)
end
```

At this point of impl here's a problem - there's no way for users to log out.
This is exactly the sort of thing our test suite should catch.(RED)

this can be fixed via:
```elixir
delete_resp_cookie("remember_token")
```


### "Remember me" checkbox

make staying logged-in optional using a "remember me" checkbox.


snippet for lib/sample_app_web/plugs/auth_plug.ex:
```heex
      <%= label f, :remember_me, class: "checkbox inline" do %>
        <%= checkbox f, :remember_me %>
        <span>Remember me on this computer</span>
      <% end %>
```
+ css styles


to checkout remember_me checkbox submit invalid creds in the login page:

```html
view module: SampleAppWeb.SessionView
controller: SampleAppWeb.SessionController
action: :create
params:
  _csrf_token: "AwFVLgEZMyMMDRUYJmBJXw5JITQOHAYOLb2t2iVtIywQE80-HyOcXQ6K"
  session: %{"email" => "a@mail.com", "password" => "123", "remember_me" => "true"}
```


```elixir
if String.to_atom(params["session"]["remember_me"]) do
  AuthPlug.remember(conn, user)
else
  conn
end
```

workaround to temporary fix a broken tests (until refactor below)
```elixir
defmodule SampleAppWeb.SessionController do
  # ...
  def create(conn, %{
        "session" => %{
          "email" => email,
          "password" => pass,
          "remember_me" => remember_me     # < in the old test has no this key
        }
      }) do
    # ... logic
  end

  def create(conn, %{"session" => session} = params) do
    session = Map.put(session, "remember_me", "false")
    params = Map.put(params, "session", session)
    create(conn, params)
  end

  # ...
end
```

## Testing

### Remember-me

add a new helper function `login_as`
> test/support/conn_test_helpers.ex
```elixir
defmodule SampleAppWeb.ConnTestHelpers do
  alias SampleAppWeb.Router.Helpers, as: Routes                            # +
  import Phoenix.ConnTest                                                  # +

  @endpoint SampleAppWeb.Endpoint                                          # +
  # ...

  # add new helper function:                                               # +
  def login_as(conn, user, opts \\ []) do
    %{password: password, remember_me: remember_me} =
      Enum.into(opts, %{password: "password", remember_me: "true"})

    post(
      conn,
      Routes.login_path(conn, :create, %{
        session: %{
          email: user.email,
          password: password,
          remember_me: remember_me
        }
      })
    )
  end
end
```

refactor

```elixir
defmodule SampleAppWeb.UserLoginTest do
  # ...

  test "login with invalid information", %{conn: conn} do
    conn = login_as(conn, %User{email: "", password: ""})                 # +
    # conn =                                                              # -
    #   post(conn, Routes.login_path(conn, :create), %{
    #     session: %{
    #       email: "",
    #       password: ""
    #     }
    #   })
  end
  # ...
end
```

### Testing the remember branch
Here about covering tests all possible options in the AuthPlug.call functions

using raise-BAD technique:
```elixir
  # ...
        case SampleApp.Token.verify_remember_token(token) do
          {:ok, user_id} ->
            if user = Accounts.get_user(user_id) do
              # raise "BAD"                                                 # +
              login(conn, user)
            else
              logout(conn)
            end
          {:error, _reason} ->
            logout(conn)
        end
  # ...
```
