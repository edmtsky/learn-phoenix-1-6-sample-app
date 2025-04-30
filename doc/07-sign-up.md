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


