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


