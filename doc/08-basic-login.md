# Basic login


mockup_of_the_login_form:
```html
================================================================================
                                                            Home  Help  Log in
--------------------------------------------------------------------------------

                                   Log in

                          Email
                          _______________________

                          Password
                          _______________________

                          [Log in]
                          New user? Sign up now!

================================================================================
```

add new routes for a new SessionController

> lib/sample_app_web/router.ex
```elixir
  #...

  scope "/", SampleAppWeb do
    pipe_through :browser

    get "/", StaticPageController, :home, as: :root
    get "/help", StaticPageController, :help, as: :help
    get "/about", StaticPageController, :about, as: :about
    get "/contact", StaticPageController, :contact, as: :contact
    get "/signup", UserController, :new, as: :signup
    post "/signup", UserController, :create, as: :signup

    get "/login", SessionController, :new, as: :login                   # +
    post "/login", SessionController, :create, as: :login               # +
    delete "/logout", SessionController, :delete, as: :logout           # +

    resources "/users", UserController
  end

  #...
```

how to see routes of the app:

```sh
mix phx.routes | grep Session
```

```
  login_path   GET     /login         SampleAppWeb.SessionController :new
  login_path   POST    /login         SampleAppWeb.SessionController :create
  logout_path  DELETE  /logout        SampleAppWeb.SessionController :delete
```

```sh
mix phx.routes | grep User
```
```
signup_path  GET     /signup             SampleAppWeb.UserController :new
signup_path  POST    /signup             SampleAppWeb.UserController :create
  user_path  GET     /users              SampleAppWeb.UserController :index
  user_path  GET     /users/:id/edit     SampleAppWeb.UserController :edit
  user_path  GET     /users/new          SampleAppWeb.UserController :new
  user_path  GET     /users/:id          SampleAppWeb.UserController :show
  user_path  POST    /users              SampleAppWeb.UserController :create
  user_path  PATCH   /users/:id          SampleAppWeb.UserController :update
             PUT     /users/:id          SampleAppWeb.UserController :update
  user_path  DELETE  /users/:id          SampleAppWeb.UserController :delete
```



Routes provided by the sessions rules:

HTTP  |  URL  |Action|       Named route       |           Purpose
------|-------|------|-------------------------|-------------------------------
GET   |/login |new   |login_path(conn, :new)   |page for a new session (login)
POST  |/login |create|login_path(conn, :create)|create a new session (login)
DELETE|/logout|delete|login_path(conn, :delete)|delete a session (log out)



### login form

mockup_of_login_failure
```html
================================================================================
                                                            Home  Help  Log in
--------------------------------------------------------------------------------
  -------------------------------------------------------------------------
 | Invalid email/password combination.                                     |
  -------------------------------------------------------------------------


                                   Log in

                          Email
                          _______________________

                          Password
                          _______________________

                          [Log in]
                          New user? Sign up now!

================================================================================
```


because here no Session model (hence no analogue for the `@changeset` variable)
so you have to use the `form_for` like so:

```heex
<%= form_for @conn, Routes.login_path(@conn, :create), [as: :session], fn f -> %>
  .
  .
  .
<% end %>
```

way to added a link to the signup page (/signup):
```heex
    <p>New user?
      <%= link "Sign up now!", to: Routes.signup_path(@conn, :new) %>
    </p>
```

```sh
curl localhost:4000/login
```

```html
<form action="/login" method="post">
  <input name="_csrf_token" type="hidden"
    value="NCdbNQYyWzIJB0ADYXMqCQM2YkclAxVRmloRvp8Vb_2RY0hSkTUpiT_4">
  <label for="session_email">Email</label>
  <input class="form-control" id="session_email"
    name="session[email]" type="email">

  <label for="session_password">Password</label>
  <input class="form-control" id="session_password"
    name="session[password]" type="password">

  <button class="btn btn-primary" type="submit">Log in</button>
</form>

<p>New user? <a href="/signup">Sign up now!</a> </p>
```

- `params["session"]["email"]`
- `params["session"]["password"]`



### Changing the layout links

add links for:
- logging out
- user settings
- listing all users
- the current user's profile page.

```html
================================================================================
                                                 Home  Help  Users  Account
--------------------------------------------------------------------v-----------
[Avatar] NickName                                         +----------------+
                                                          |  Profile       |
                                                          |  Settings      |
                                                          |----------------|
                                                          |  Log out       |
                                                          +----------------+


================================================================================
```

```heex
<%= if @current_user do %>
  # Links for logged-in users
<% else %>
  # Links for non-logged-in-users
<% end %>
```

dropdown menus made by Bootstrap's CSS classes such as `dropdown` `dropdown-menu`


### Testing layout changes

a series of steps to verify the following sequence of actions:

1. Visit the login path.
2. Post valid information to the sessions path.
3. Verify that the login link disappears.
4. Verify that a logout link appears.
5. Verify that a profile link appears.


to check logging in redirects to the user show page:
```elixir
assert redir_path = redirected_to(conn) == Routes.user_path(conn, :show, user)
```

Убедитесь, что ссылка входа в систему исчезает, подтверждая, что на странице
нет ссылок пути входа в систему:
verify the login link disappears
(there are no login path links on the page)
```elixir
|> refute_select("a[href='#{Routes.login_path(conn, :new)}']")
```

Because the application code was already working, this test should be GREEN:
Listing_8_24: GREEN
```sh
mix test test/sample_app_web/integration/user_login_test.exs
```


### logout

RESTful action delete means logout.

```elixir
defmodule SampleAppWeb.AuthPlug do
  import Plug.Conn
  # ...

  # Logs out the current user.
  def logout(conn) do                          # +
    conn                                       # +
    |> configure_session(drop: true)           # + cleanup cookie in frontend
    |> assign(:current_user, nil)              # + cleanup user in backend
  end                                          # +
end
```


```elixir
defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleAppWeb.AuthPlug

  # for logout
  def delete(conn, _params) do                       # +
    conn                                             # +
    |> AuthPlug.logout()                             # +
    |> redirect(to: Routes.root_path(conn, :home))   # + redirect to /
  end                                                # +
end
```


### learned things:

- Phoenix can maintain state from one page to the next
  using temporary cookies via the `session` method.
- The login form is designed to create a new session to log a user in.
- Using the `session` method, we can securely place a user id on the browser
  to create a temporary session.
- We can change features such as links on the layouts based on login status.
- Integration tests can verify correct routes, database updates, and
  proper changes to the layout.

