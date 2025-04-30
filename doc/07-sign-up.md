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
