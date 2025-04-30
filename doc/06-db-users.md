## Add the data model for Users

A mockup of the user signup page.
```html
                          Sign up

                    Name:         ____
                    Email:        ____
                    Password:     ____
                    Confirmation: ____

                    [Create my account]
```

generate an `Accounts` context to manage a `User` schema with
`name` and `email` attributes:

```sh
mix phx.gen.context Accounts User users name:string email:string

* creating lib/sample_app/accounts/user.ex
* creating priv/repo/migrations/20250428123403_create_users.exs
* creating lib/sample_app/accounts.ex
* injecting lib/sample_app/accounts.ex
* creating test/sample_app/accounts_test.exs
* injecting test/sample_app/accounts_test.exs
* creating test/support/fixtures/accounts_fixtures.ex
* injecting test/support/fixtures/accounts_fixtures.ex

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```

generated code:

./priv/repo/migrations/20250428123403_create_users.exs
```elixir
defmodule SampleApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do   # the table name is "users"
      add :name, :string      # the columns name and type
      add :email, :string

      timestamps()
    end
  end
end
```

The User schema produced by `mix phx.gen.context Accounts ...`
```
    +-------------------------+
    |          users          |
    +-------------------------+
    |     id      | integer   |
    |-------------|-----------+
    | name        | string    |
    | email       | string    |
    | inserted_at | datetime  |
    | updated_at  | datetime  |
    +-------------------------+
```

- `timestamps()`, is a special function that creates two columns
   - `inserted_at` - timestamps when a given user is inserted
   - `updated_at` - timestamp when a given user is updated
   (Both if these columns are filled automatically)


```sh
mix ecto.migrate

# Compiling 19 files (.ex)
# Generated sample_app app
#
# 15:39:13.546 [info]  == Running 20250428123403 SampleApp.Repo.Migrations.CreateUsers.change/0 forward
#
# 15:39:13.558 [info]  create table users
#
# 15:39:13.758 [info]  == Migrated 20250428123403 in 0.1s
```


```sh
mix ecto.dump
```
The structure for SampleApp.Repo has been dumped to
> priv/repo/structure.sql
```sql
--
-- PostgreSQL database dump
--

-- Dumped from database version ...
-- Dumped by pg_dump version ...

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255),
    email character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20250428123403);
```



## The schema file of User

> lib/sample_app/accounts/user.ex

```elixir
defmodule SampleApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end
```

An `Ecto` schema is used to map any data source (for example a database table)
into an Elixir struct.


play around with Interactive Elixir shell(iex) to research `__meta__` field:

```sh
iex -S mix
```
```html
Term
  %SampleApp.Accounts.User{
    __meta__: #Ecto.Schema.Metadata<:built, "users">,
    email: nil, id: nil, inserted_at: nil, name: nil, updated_at: nil
  }

Data type
  SampleApp.Accounts.User

Description
  This is a struct. Structs are maps with a __struct__ key.

Reference modules
  SampleApp.Accounts.User, Map

Implemented protocols
  IEx.Info, Inspect, Jason.Encoder, Phoenix.Param, Plug.Exception,
  Swoosh.Email.Recipient
```

This shows that the `%SampleApp.Accounts.User{}` has a `__meta__` field
holding the status of the struct and what database table it matches.(users)


Creating user structs and add(save) to db via Repo.insert

```sh
iex -S mix
```

```elixir
iex(1)> alias SampleApp.Accounts
SampleApp.Accounts

iex(2)> alias SampleApp.Accounts.User
SampleApp.Accounts.User

iex(3)>  alias SampleApp.Repo
SampleApp.Repo

iex(4)> user = %User{name: "EDmtsky", email: "edmtsky@example.com"}
%SampleApp.Accounts.User{
  __meta__: #Ecto.Schema.Metadata<:built, "users">,
  email: "edmtsky@example.com",
  id: nil,
  inserted_at: nil,
  name: "EDmtsky",
  updated_at: nil
}

iex(5)> {:ok, user0} = Repo.insert(user)
[debug] QUERY OK db=30.8ms decode=5.8ms queue=0.6ms idle=1712.9ms
INSERT INTO "users" ("email","name","inserted_at","updated_at") VALUES ($1,$2,$3,$4) RETURNING "id" ["edmtsky@example.com", "EDmtsky", ~N[2025-04-28 13:53:42], ~N[2025-04-28 13:53:42]]
{:ok,
 %SampleApp.Accounts.User{
   __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
   email: "edmtsky@example.com",
   id: 1,
   inserted_at: ~N[2025-04-28 13:53:42],
   name: "EDmtsky",
   updated_at: ~N[2025-04-28 13:53:42]
 }}
iex(6)> i user0.inserted_at
```
```html
Term
  ~N[2025-04-28 13:53:42]

Data type
  NaiveDateTime

Description
  This is a struct representing a "naive" datetime
  (that is, a datetime without a time zone).
  It is commonly represented using the `~N` sigil syntax,
  that is defined in the `Kernel.sigil_N/2` macro.

Raw representation
  %NaiveDateTime{calendar: Calendar.ISO, day: 28, hour: 13, microsecond: {0, 0}, minute: 53, month: 4, second: 42, year: 2025}

Reference modules
  NaiveDateTime, Calendar, Map

Implemented protocols
  IEx.Info, Inspect, Jason.Encoder, Phoenix.HTML.Safe, Phoenix.Param,
  Plug.Exception, String.Chars, Swoosh.Email.Recipient
```

delete user from db

```elixir
iex(8)> {:ok, user0} = Repo.delete(user0)
[debug] QUERY OK db=14.2ms queue=0.4ms idle=1286.8ms
DELETE FROM "users" WHERE "id" = $1 [1]
{:ok,
 %SampleApp.Accounts.User{
   __meta__: #Ecto.Schema.Metadata<:deleted, "users">,
   email: "edmtsky@example.com",
   id: 1,
   inserted_at: ~N[2025-04-28 13:53:42],
   name: "EDmtsky",
   updated_at: ~N[2025-04-28 13:53:42]
 }}
```


the `Accounts` context manages the `User` schema, and
function `create_user` can be used o insert a user utilizing `Repo.insert`:

> lib/sample_app/accounts.ex
```elixir
defmodule SampleApp.Accounts do
  alias SampleApp.Repo
  alias SampleApp.Accounts.User

  def create_user(attrs \\ %{}) do # <<<
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
```

add length for name and email and validate_format for email:

```elixir
defmodule SampleApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_email_regex ~r/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)
  end
end
```


## Validate uniqueness (for email)

validate_uniqueness for email needs db-index for email column,
so create migration to add index:

```elixir
mix ecto.gen.migration add_unique_index_to_users_email
Compiling 2 files (.ex)
* creating priv/repo/migrations/20250429170756_add_unique_index_to_users_email.exs
```


Unlike the migration for `users`,
the `email` uniqueness migration is not pre-defined, so
you need to fill in its contents with:

given code-snippert for a new migration:
```elixir
defmodule SampleApp.Repo.Migrations.AddUniqueIndexToUsersEmail do
  use Ecto.Migration

  def change do
    # .. place for code
  end
end
```

> priv/repo/migrations/20250429170756_add_unique_index_to_users_email.exs
```elixir
defmodule SampleApp.Repo.Migrations.AddUniqueIndexToUsersEmail do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
    #^macro ^Ecto-func  ^table_name ^column_name
  end
end
```


```elixir
defmodule SampleApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  #...

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)

    |> update_change(:email, &String.downcase/1)           # <<< +
    |> unique_constraint(:email)                           # <<< +
  end
```



### Adding a secure password

supplied the User schema with the `password_hash` field and install `Argon2`

```sh
mix ecto.gen.migration add_password_hash_to_users
* creating priv/repo/migrations/20250430042846_add_password_hash_to_users.exs
```

priv/repo/migrations/20250430042846_add_password_hash_to_users.exs
```elixir
defmodule SampleApp.Repo.Migrations.AddPasswordHashToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :string, default: "", null: false
    end
  end
end
```

```sh
mix ecto.migrate

# 07:31:51.892 [info]  == Running 20250430042846 SampleApp.Repo.Migrations.AddPasswordHashToUsers.change/0 forward
#
# 07:31:51.902 [info]  alter table users
#
# 07:31:51.907 [info]  == Migrated 20250430042846 in 0.0s
```

add dep:
```elixir
      {:argon2_elixir, "2.4.0"},
```

```sh
mix deps.get

# ...
# New:
#   argon2_elixir 2.4.0
#   comeonin 5.5.1
#   elixir_make 0.9.0
# * Getting argon2_elixir (Hex package)
# * Getting comeonin (Hex package)
# * Getting elixir_make (Hex package)
```


implement password system with the help of virtual fields:

> lib/sample_app/accounts/user.ex
```elixir
defmodule SampleApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_email_regex ~r/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  @required_fields [:name, :email, :password, :password_confirmation]     # <<<

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string                              # +
    timestamps()
    field :password, :string, virtual: true                    # +
    field :password_confirmation, :string, virtual: true       # +
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)                           # +
    |> validate_required(@required_fields)                     # +
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)
    |> validate_confirmation(:password, message: "does not match password") # +
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_password_hash()                                     # +
  end

  # new:
  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        if password do
          put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
        else
          changeset
        end
      _ ->
        changeset
    end
  end
end
```


### Minimum password length

- password: {"should be at least %{count} character(s)"
- password_confirmation: {"can't be blank", ..



### ExMachina package

package `ExMachina` works great with `Ecto` and
makes it easy to create test data associations.
mix.exs
```elixir
  {:ex_machina, "2.7.0", only: :test}
```

> Note:
  The original generated `Account` context test had a `user_fixture` function,
  that uses the `Accounts.create_user` function to create test user data.
  That seems like a good pattern to follow at first, but
  if you change how `Accounts.create_user` works
  and it happens to be buggy, a lot of tests will break.

  It might seem you did a lot for so little, but
  when you are inserting many different test data,
  `ExMachina` will save you a headache.



`ExMachina` calls the generators for test data _factories_.


create a `Factory` module
which will includes all our factories separated in individual files

> test/support/factory.ex
```elixir
defmodule SampleApp.Factory do
  use ExMachina.Ecto, repo: SampleApp.Repo
  use SampleApp.UserFactory
end
```

create a `User` factory so we can create test users

> test/factories/user_factory.ex
```elixir
defmodule SampleApp.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %SampleApp.Accounts.User{
          name: sequence(:name, &"Example User#{&1}"),
          email: sequence(:email, &"user-#{&1}@example.com"),
          password: "password",
          password_confirmation: "password",
          password_hash: Argon2.hash_pwd_salt("password")
        }
      end
    end
  end
end
```

update `mix.exs` file to compile factory files in `test/factories/` -
adding the `test/factories/` path to the `elixirc_paths`:

> mix.exs
```elixir
  # ...

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/factories"] # <<
  #                                                       ^^^^^^^^^^^^^^
  defp elixirc_paths(_), do: ["lib"]

  # ...
```


start the `ex_machina` application in `test/test_helper.exs`

> test/test_helper.exs
```elixir
{:ok, _} = Application.ensure_all_started(:ex_machina)                     # +
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SampleApp.Repo, :manual)
```

refactor all `Accounts` context tests to use ex_machina factory.


### add Accounts.authenticate_by_email_and_pass

```elixir
  def authenticate_by_email_and_pass(email, given_pass) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Argon2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Argon2.no_user_verify()
        {:error, :not_found}
    end
  end
```

manual verification of creation and authenticate

```elixir
iex> alias SampleApp.Accounts
SampleApp.Accounts
iex> alias SampleApp.Accounts.User
SampleApp.Accounts.User

iex> Accounts.create_user(%{name: "John Doe", email: "john@example.com", password: "secret"})
{:error,
 #Ecto.Changeset<
   action: :insert,
   changes: %{email: "john@example.com", name: "John Doe", password: "secret"},
   errors: [password_confirmation: {"can't be blank", [validation: :required]}],
   data: #SampleApp.Accounts.User<>,
   valid?: false
 >}

iex> Accounts.create_user(%{
  name: "John Doe",
  email: "john@example.com",
  password: "secret", password_confirmation: "secret"})

# [debug] QUERY OK db=20.8ms decode=4.9ms queue=0.6ms idle=1155.3ms
# INSERT INTO "users" ("email","name","password_hash","inserted_at","updated_at") VALUES ($1,$2,$3,$4,$5) RETURNING "id" ["john@example.com", "John Doe", "$argon2id$v=19$m=131072,t=8,p=4$urP5DtLf1MtQebPuYlLbBA$5ej1EhFogZoi0sLHt3W2gyrFgL7PvAo0P+vi4csdEkQ", ~N[2025-04-30 06:42:42], ~N[2025-04-30 06:42:42]]
{:ok,
 %SampleApp.Accounts.User{
   __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
   email: "john@example.com",
   id: 2,
   inserted_at: ~N[2025-04-30 06:42:42],
   name: "John Doe",
   password: "secret",
   password_confirmation: "secret",
   password_hash: "$argon2id$v=19$m=131072,t=8,p=4$urP5DtLf1MtQebPuYlLbBA$5ej1EhFogZoi0sLHt3W2gyrFgL7PvAo0P+vi4csdEkQ",
   updated_at: ~N[2025-04-30 06:42:42]
 }}

iex> Accounts.authenticate_by_email_and_pass("john@example.com", "secret")
# [debug] QUERY OK source="users" db=0.6ms queue=0.5ms idle=1494.3ms
# SELECT u0."id", u0."email", u0."name", u0."password_hash", u0."inserted_at", u0."updated_at" FROM "users" AS u0 WHERE (u0."email" = $1) ["john@example.com"]
{:ok,
 %SampleApp.Accounts.User{
   __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
   email: "john@example.com",
   id: 2,
   inserted_at: ~N[2025-04-30 06:42:42],
   name: "John Doe",
   password: nil,
   password_confirmation: nil,
   password_hash: "$argon2id$v=19$m=131072,t=8,p=4$urP5DtLf1MtQebPuYlLbBA$5ej1EhFogZoi0sLHt3W2gyrFgL7PvAo0P+vi4csdEkQ",
   updated_at: ~N[2025-04-30 06:42:42]
 }}
```

to cleanup whole database:
```sh
mix ecto.reset
```
when your dbuser has no permission to create a database:

The database for SampleApp.Repo has been dropped
** (Mix) The database for SampleApp.Repo couldn't be created: ERROR 42501 (insufficient_privilege) permission denied to create database


how to fix:

```sql
CREATE DATABASE sample_app_dev WITH OWNER dbuser;
```

```sh
mix ecto.migrate

# 09:49:16.524 [info]  == Running 20250428123403 SampleApp.Repo.Migrations.CreateUsers.change/0 forward
#
# 09:49:16.536 [info]  create table users
#
# 09:49:16.619 [info]  == Migrated 20250428123403 in 0.0s
#
# 09:49:16.714 [info]  == Running 20250429170756 SampleApp.Repo.Migrations.AddUniqueIndexToUsersEmail.change/0 forward
#
# 09:49:16.714 [info]  create index users_email_index
#
# 09:49:16.766 [info]  == Migrated 20250429170756 in 0.0s
#
# 09:49:16.781 [info]  == Running 20250430042846 SampleApp.Repo.Migrations.AddPasswordHashToUsers.change/0 forward
#
# 09:49:16.781 [info]  alter table users
#
# 09:49:16.782 [info]  == Migrated 20250430042846 in 0.0s
```


