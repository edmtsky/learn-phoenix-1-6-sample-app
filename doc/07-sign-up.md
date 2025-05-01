# mockup user profile

A mockup of the user profile made in this section:
```
=============================================================
[            ] NickName
[  Avatar    ]
[            ]


=============================================================
```


A mockup of our best guess at the final profile page:
```
=============================================================
[            ] Nick          Microposts (3)
[  Avatar    ]               ---------------------------
[            ]               Lorem ipsum dolor sit ament,
50        77                 Posted 1 day ago.
following followers          ---------------------------
                             Consectetur adipisicing elit
                             Posted 2 day ago.
                             ---------------------------
                             Lorem ipsum dolor sit ament
                             Posted 3 day ago.


=============================================================
```


## create user in dev db

```sh
iex -S mix

iex> SampleApp.Accounts.create_user(%{
      name: "Edmtsky",
      email: "edmtsky@example.com",
      password: "secret",
      password_confirmation: "secret"
    })
```
output:
```html
[debug] QUERY OK db=30.4ms decode=5.4ms queue=0.9ms idle=1493.4ms
INSERT INTO "users" ("email","name","password_hash","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5) RETURNING "id" ["edmtsky@example.com", "Edmtsky", "$argon2id$v=19$m=131072,t=8,p=4$eM0Gi0UIo+s3/P/LdoNGPA$Wwzl4Gu1hqzyrfe4Paf/drgkeDYp/JJDYpfLBYDLIdQ", ~N[2025-04-30 13:16:35], ~N[2025-04-30 13:16:35]]

{:ok,
 %SampleApp.Accounts.User{
   __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
   email: "edmtsky@example.com",
   id: 1,
   inserted_at: ~N[2025-04-30 13:16:35],
   name: "Edmtsky",
   password: "secret",
   password_confirmation: "secret",
   password_hash: "$argon2id$v=19$m=131072,t=8,p=4$eM0Gi0UIo+s3/P/LdoNGPA$Wwzl4Gu1hqzyrfe4Paf/drgkeDYp/JJDYpfLBYDLIdQ",
   updated_at: ~N[2025-04-30 13:16:35]
 }}
```


| HTTP  |      URL      | Action |           Named route           |           Purpose
|-------|---------------|--------|---------------------------------|-----------------------------
| GET   | /users        | index  | users_path(conn, :index)        | page to list all users
| GET   | /users/1      | show   | users_path(conn, :show, user)   | page to show user with id 1
| GET   | /users/new    | new    | users_path(conn, :new)          | page to make a new user
| POST  | /users        | create | users_path(conn, :create)       | create a new user
| GET   | /users/1/edit | edit   | users_path(conn, :edit, user)   | page to edit user with id 1
| PATCH | /users/1      | update | users_path(conn, :update, user) | update user with id 1
| DELETE| /users/1      | delete | users_path(conn, :delete, user) | delete user with id 1

RESTful routes provided by the `resources "/users", UserController` in router.ex


localhost:4000/users/1

```html
sample app                                                Home Help Log in

Edmtsky, edmtsky@example.com
created: 2025-04-30T13:16:35
updated: 2025-04-30T13:16:35
now: 2025-04-30T13:21:27.829204

--------------------------------------------------------------------------------
The Phoenix Tutorial by Edmtsky                             About Contact
--------------------------------------------------------------------------------

view module: SampleAppWeb.UserView
controller: SampleAppWeb.UserController
action: :show params: id: "1"
```


### IEx.pry - interactive debugging your application.


iex(2)> h IEx.pry

> defmacro pry()

Pries into the process environment.

This is useful for debugging a particular chunk of code when executed by a
particular process. The process becomes the evaluator of IEx commands and is
temporarily changed to have a custom group leader. Those values are reverted by
calling IEx.Helpers.respawn/0, which starts a new IEx shell, freeing up the
pried one.

When a process is pried, all code runs inside IEx and has access to all imports
and aliases from the original code. However, the code is evaluated and
therefore cannot access private functions of the module being pried.
Module functions still need to be accessed via Mod.fun(args).


> example of how to use `IEx.pry`:

```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    require IEx                                # ++
    IEx.pry                                    # ++
    render(conn, "show.html", user: user)
  end
end
```

term1:
```sh
iex -S mix phx.server
```

term2:
```sh
curl localhost:4000/users/1
```

term1:
```elixir
# [debug] Processing with SampleAppWeb.UserController.show/2
...
#    10:     user = Accounts.get_user!(id)
#    11:     require IEx
#    12:     IEx.pry()
#    13:     render(conn, "show.html", user: user)
#    14:   end
#
# Allow? [Yn] y
```

```elixir
pry> user.name
"Binh Tran"
pry> user.email
"binh@example.com"
pry> id
"1"

# continue work
pry> continue
```

Whenever you're confused about something in a Phoenix application,
it's good practice to put `require IEx`; `IEx.pry` close to
the code you think might be causing the trouble.
Inspecting the state of the system using `IEx.pry` is
a powerful function for tracking down application errors and
interactively debugging your application.


```elixir
...
pry(1)> conn
%Plug.Conn{
  adapter: {Plug.Cowboy.Conn, :...},
  assigns: %{},
  cookies: %{
  # ...
  },
  halted: false,
  host: "127.0.0.1",
  method: "GET",
  # ...
  params: %{"id" => "1"},
  # ...
}
```


```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts

  def new(conn, _params) do
    require IEx; IEx.pry                      # << ++ "breakpoint"
    render(conn, "new.html")
  end
  # ...
```

term1:
```sh
iex -S mix phx.server
```

term2:
```sh
curl localhost:4000/users/new
```

```elixir
# Allow? [Yn] y

# Interactive Elixir (1.12.3) - press Ctrl+C to exit (type h() ENTER for help)
pry(1)> conn
%Plug.Conn{
  adapter: {Plug.Cowboy.Conn, :...},
  assigns: %{},
  body_params: %{},
  cookies: %{#...
  },
  halted: false,
  host: "127.0.0.1",
  method: "GET",
  params: %{},
  path_info: ["users", "new"],
  # ...
}

pry(2)> _params

iex(1)> warning: the underscored variable "_params" is used after being set. A leading underscore indicates that the value of the variable should be ignored. If this is intended please rename the variable to remove the underscore
  lib/sample_app_web/controllers/user_controller.ex:2: SampleAppWeb.UserController.new/2

%{}
```


### Gavatar image and sidebar

old:
```heex
<%= @user.name %>, <%= @user.email %>
<div>
  <div>created: <%= @user.inserted_at %> </div>
  <div>updated: <%= @user.updated_at %> </div>
  <div>now: <%= NaiveDateTime.utc_now() %></div>
</div>
```

new
```heex
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <h1>
        <%= gravatar_for(@user) %>
        <%= @user.name %>
      </h1>
    </section>
  </aside>
</div>
```



```elixir
defmodule SampleAppWeb.UserView do
  use SampleAppWeb, :view

  defp md5_hexdigest(str) do
    :crypto.hash(:md5, str)
    |> Base.encode16(case: :lower)
  end

  # Returns the Gravatar for the given user.
  def gravatar_for(user) do
    gravatar_id = String.downcase(user.email) |> md5_hexdigest()
    gravatar_url = ["https://secure.gravatar.com/avatar/", gravatar_id]
    img_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
```

add support for an optional size parameter

```elixir
  def gravatar_for(user, options \\ []) do                                 # *
    gravatar_id = String.downcase(user.email) |> md5_hexdigest()
    size = Keyword.get(options, :size, 80) |> to_string()                  # +
    gravatar_url = ["https://secure.gravatar.com/avatar/",                 # +
                    gravatar_id, "?s=", size]                              # +
    img_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
```


### Using form_for

`form_for` is a Phoenix helper function used for signup form.
`form_for` takes three arguments: a `changeset`, a `path`, and an anonymous function.
The anonymous function takes one argument, the form data we're labeling `f`.

> lib/sample_app_web/controllers/user_controller.ex
```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User                      # +

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})        # +
    render(conn, "new.html", changeset: changeset)   # +
  end

  # ...
end
```

> lib/sample_app_web/templates/user/new.html.heex
```heex
<h1>Sign up</h1>

<div class="row">
  <div class="mx-auto col-md-6 col-md-offset-3">
    <%= form_for @changeset, Routes.user_path(@conn, :create), fn f -> %>
      <%= label :user, :name %>
      <%= text_input f, :name %>

      <%= label :user, :email %>
      <%= email_input f, :email %>

      <%= label :user, :password %>
      <%= password_input f, :password %>

      <%= label :user, :password_confirmation, "Confirmation" %>
      <%= password_input f, :password_confirmation %>

      <%= submit "Create my account", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>
```


### Signup error messages

`resources "/users", UserController`  - add RESTful actions, in particular
on `POST /users` it will be call :create action in the controller, so:

```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User

  # ...

  # to handle POST /users (submite signup form)
  def create(conn, %{"user" => user_params}) do            # << ++
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn

      # Handle a successful User insertion.
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # ...
end
```

add error_count_tag

> lib/sample_app_web/views/error_helpers.ex
```elixir
defmodule SampleAppWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  def error_count_tag(form) do                                              # +
    error_count = Enum.count(form.errors)                                   # +

    content = [                                                             # +
      "The form contains ",                                                 # +
      Gettext.ngettext(SampleAppWeb.Gettext, "1 error", "%{count} errors",  # +
      error_count),                                                         # +
      "."
    ]

    content_tag(:div, content, class: "alert alert-danger")                 # +
  end                                                                       # +

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end
  # ...
end
```

example of how to handle pluralization of words:

```elixir
iex> Gettext.ngettext(SampleAppWeb.Gettext, "1 error", "%{count} errors", 1)
"1 error"

iex> Gettext.ngettext(SampleAppWeb.Gettext, "1 error", "%{count} errors", 5)
"5 errors"

iex> Gettext.ngettext(SampleAppWeb.Gettext, "1 woman", "%{count} women", 2)
"2 women"

iex> Gettext.ngettext(SampleAppWeb.Gettext, "1 erratum", "%{count} errata", 3)
"3 errata"
```


add code to display error messages on the signup form:

> lib/sample_app_web/templates/user/new.html.heex
```heex
<h1>Sign up</h1>

<div class="row">
  <div class="mx-auto col-md-6 col-md-offset-3">
    <%= form_for @changeset, Routes.user_path(@conn, :create), fn f -> %>
      <%= if @changeset.action, do: error_count_tag f %>

      <div class="form-group">
        <%= label :user, :name %>
        <%= text_input f, :name, class: "form-control" %>
        <!--                     ^^^^^^^^^^^^^^^^^^^^ -->
        <%= error_tag f, :name %>                                  <!-- <<< -->
      </div>

      <div class="form-group">
        <%= label :user, :email %>
        <%= email_input f, :email, class: "form-control" %>
        <!--                       ^^^^^^^^^^^^^^^^^^^^ -->
        <%= error_tag f, :email %>                                 <!-- <<< -->
      </div>

      <div class="form-group">
        <%= label :user, :password %>
        <%= password_input f, :password, class: "form-control" %>
        <!--                             ^^^^^^^^^^^^^^^^^^^^ -->
        <%= error_tag f, :password %>                              <!-- <<< -->
      </div>

      <div class="form-group">
        <%= label :user, :password_confirmation, "Confirmation" %>
        <%= password_input f, :password_confirmation, class: "form-control" %>
        <!--                                          ^^^^^^^^^^^^^^^^^^^^ -->
        <%= error_tag f, :password_confirmation %>                <!-- <<< -->
      </div>
      <%= submit "Create my account", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>
```

## use /signup URL for form submition(POST request) instead of /users(default)

> lib/sample_app_web/templates/user/new.html.heex
```heex
<h1>Sign up</h1>

<div class="row">
  <div class="mx-auto col-md-6 col-md-offset-3">
    <%= form_for @changeset, Routes.signup_path(@conn, :create), fn f -> %>
                                    ^^^^
```

router.ex
```elixir
  scope "/", SampleAppWeb do
    pipe_through :browser

    get "/", StaticPageController, :home, as: :root
    get "/help", StaticPageController, :help, as: :help
    get "/about", StaticPageController, :about, as: :about
    get "/contact", StaticPageController, :contact, as: :contact
    get "/signup", UserController, :new, as: :signup
    post "/signup", UserController, :create, as: :signup              # << add
    resources "/users", UserController
  end
```

add integration test for invalid signup submition:

```elixir
defmodule SampleAppWeb.UserSignupTest do
  use SampleAppWeb.ConnCase, async: true
  alias SampleAppWeb.Endpoint

  test "invalid signup information", %{conn: conn} do
    user_records_before = Repo.one(from u in User, select: count())

    conn =
      conn
      |> get(Routes.signup_path(conn, :new))              # GET /signup
      |> post(Routes.signup_path(conn, :create), %{       # POST /signup
        user: %{
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      })

    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before == user_records_after

    html_response(conn, 200)
    # CSS class for the error count tag
    |> assert_select("div.alert-danger")
    # CSS class for field with error explanation
    |> assert_select("span.invalid-feedback", count: 4)
    # make sure that `<form  action="/signup"` not `/users`(what was by default)
    |> assert_select("form[action='#{Routes.signup_path(Endpoint, :create)}']")
    #                                       ^ /signup
  end
end
```


### finished signup form

The user create action with an insert and a redirect.
> lib/sample_app_web/controllers/user_controller.ex
```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  # ...

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->                                              # *
        conn
        |> redirect(to: Routes.user_path(conn, :show, user))      # +

      # Handle a successful User insertion.
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
  #...
end
```

now after successful signup automaticaly redirected to
http://127.0.0.1:4000/users/2

check is valid signup sure create a new user:
```elixir
iex> import Ecto.Query
Ecto.Query
iex> SampleApp.Repo.one(from u in SampleApp.Accounts.User, select: count())
[debug] QUERY OK source="users" db=5.4ms decode=6.1ms queue=42.8ms idle=813.3ms
SELECT count(*) FROM "users" AS u0 []
2
```


### add The flash message

add a message that appears on the subsequent page
(in this case, welcoming a new user to the application) and
then disappears upon visiting a second page or on page reload.

`flash` is a special map in conn (Plug.Conn) used to display temporary messages

```elixir
defmodule SampleAppWeb.UserController do
  # ...

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "Welcome to the Sample App!")  # <<<<
        |> redirect(to: Routes.user_path(conn, :show, user))

       # ...
    end
  end
```

> lib/sample_app_web/templates/layout/app.html.heex
add flash message to html response:
```heex
    <%= for {message_type, message} <- get_flash(@conn) do %>
      <div class={"alert alert-#{message_type}"}>
        <%= message %>
      </div>
    <% end %>
```

this
```heex

      <div class={"alert alert-#{message_type}"}>
        <%= message %>
      </div>
```
can be replaces with:
```heex
      <%= content_tag(:div, message, class: "alert alert-#{message_type}") %>
```
