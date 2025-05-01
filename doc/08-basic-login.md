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
