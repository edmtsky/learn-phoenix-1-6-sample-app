
```sh
mix phx.new sample_app
* creating sample_app/config/config.exs
* creating sample_app/config/dev.exs
* creating sample_app/config/prod.exs
* creating sample_app/config/runtime.exs
* creating sample_app/config/test.exs
* creating sample_app/lib/sample_app/application.ex
* creating sample_app/lib/sample_app.ex
* creating sample_app/lib/sample_app_web/views/error_helpers.ex
* creating sample_app/lib/sample_app_web/views/error_view.ex
* creating sample_app/lib/sample_app_web/endpoint.ex
* creating sample_app/lib/sample_app_web/router.ex
* creating sample_app/lib/sample_app_web/telemetry.ex
* creating sample_app/lib/sample_app_web.ex
* creating sample_app/mix.exs
* creating sample_app/README.md
* creating sample_app/.formatter.exs
* creating sample_app/.gitignore
* creating sample_app/test/support/channel_case.ex
* creating sample_app/test/support/conn_case.ex
* creating sample_app/test/test_helper.exs
* creating sample_app/test/sample_app_web/views/error_view_test.exs
* creating sample_app/lib/sample_app/repo.ex
* creating sample_app/priv/repo/migrations/.formatter.exs
* creating sample_app/priv/repo/seeds.exs
* creating sample_app/test/support/data_case.ex
* creating sample_app/lib/sample_app_web/controllers/page_controller.ex
* creating sample_app/lib/sample_app_web/views/page_view.ex
* creating sample_app/test/sample_app_web/controllers/page_controller_test.exs
* creating sample_app/test/sample_app_web/views/page_view_test.exs
* creating sample_app/assets/vendor/topbar.js
* creating sample_app/lib/sample_app_web/templates/layout/root.html.heex
* creating sample_app/lib/sample_app_web/templates/layout/app.html.heex
* creating sample_app/lib/sample_app_web/templates/layout/live.html.heex
* creating sample_app/lib/sample_app_web/views/layout_view.ex
* creating sample_app/lib/sample_app_web/templates/page/index.html.heex
* creating sample_app/test/sample_app_web/views/layout_view_test.exs
* creating sample_app/lib/sample_app/mailer.ex
* creating sample_app/lib/sample_app_web/gettext.ex
* creating sample_app/priv/gettext/en/LC_MESSAGES/errors.po
* creating sample_app/priv/gettext/errors.pot
* creating sample_app/assets/css/phoenix.css
* creating sample_app/assets/css/app.css
* creating sample_app/assets/js/app.js
* creating sample_app/priv/static/robots.txt
* creating sample_app/priv/static/images/phoenix.png
* creating sample_app/priv/static/favicon.ico

Fetch and install dependencies? [Yn] n

We are almost there! The following steps are missing:

    $ cd sample_app
    $ mix deps.get

Then configure your database in config/dev.exs and run:

    $ mix ecto.create

Start your Phoenix app with:

    $ mix phx.server

You can also run your app inside IEx (Interactive Elixir) as:

    $ iex -S mix phx.server
```

fetch all dependencies (with potentially broken versions)
```sh
mix deps.get

Resolving Hex dependencies...
Resolution completed in 1.317s
New:
  castore 1.0.12
  cowboy 2.13.0
  cowboy_telemetry 0.4.0
  cowlib 2.15.0
  db_connection 2.7.0
  decimal 2.3.0
  ecto 3.12.5
  ecto_sql 3.12.1
  esbuild 0.9.0
  expo 1.1.0
  file_system 1.1.0
  floki 0.37.1
  gettext 0.26.2
  jason 1.4.4
  mime 2.0.6
  phoenix 1.6.16
  phoenix_ecto 4.6.3
  phoenix_html 3.3.4
  phoenix_live_dashboard 0.5.3
  phoenix_live_reload 1.6.0
  phoenix_live_view 0.16.4
  phoenix_pubsub 2.1.3
  phoenix_template 1.0.4
  phoenix_view 2.0.4
  plug 1.17.0
  plug_cowboy 2.7.3
  plug_crypto 1.2.5
  postgrex 0.20.0
  ranch 2.2.0
  swoosh 1.18.4
  telemetry 1.3.0
  telemetry_metrics 0.6.2
  telemetry_poller 1.2.0
```


fix versions of transitive deps

```sh
mix fix.lock

Determine point of time by phoenix 1.6.2 ...
Point of time: 2021-10-09 - 2021-12-08

Fetching release dates of transitive dependencies...
  - phoenix_pubsub  (locked: 2.1.3)
  - ranch  (locked: 2.2.0)
  - mime  (locked: 2.0.6)
  - expo  (locked: 1.1.0)
[WARNING] Cannot get correct version for expo
  - phoenix_view  (locked: 2.0.4)
  - cowlib  (locked: 2.15.0)
  - plug  (locked: 1.17.0)
  - db_connection  (locked: 2.7.0)
  - decimal  (locked: 2.3.0)
  - telemetry  (locked: 1.3.0)
  - file_system  (locked: 1.1.0)
  - cowboy  (locked: 2.13.0)
  - plug_crypto  (locked: 1.2.5)
  - ecto  (locked: 3.12.5)
  - castore  (locked: 1.0.12)
  - cowboy_telemetry  (locked: 0.4.0)
  - phoenix_template  (locked: 1.0.4)
[WARNING] Cannot get correct version for phoenix_template

Code snippet for mix.exs with exact versions:

      {:castore, "0.1.13"},
      {:cowboy, "2.9.0"},
      {:cowboy_telemetry, "0.4.0"},
      {:cowlib, "2.11.0"},
      {:db_connection, "2.4.1"},
      {:decimal, "2.0.0"},
      {:ecto, "3.7.1"},
      {:file_system, "0.2.10"},
      {:mime, "2.0.2"},
      {:phoenix_pubsub, "2.0.0"},
      {:phoenix_view, "1.0.0"},
      {:plug, "1.12.1"},
      {:plug_crypto, "1.2.2"},
      {:ranch, "1.8.0"},
      {:telemetry, "1.0.0"},


Next steps:

    1. copy generated code into the deps block in your mix.exs file
    2. mix deps.clean --all --unlock
    3. mix deps.get
    4. mix compile

```


refetch deps with fixed versions

```sh
mix deps.clean --all --unlock && mix deps.get

Resolving Hex dependencies...
Resolution completed in 0.576s
New:
  castore 0.1.13
  connection 1.1.0
  cowboy 2.9.0
  cowboy_telemetry 0.4.0
  cowlib 2.11.0
  db_connection 2.4.1
  decimal 2.0.0
  ecto 3.7.1
  ecto_sql 3.7.2
  esbuild 0.4.0
  file_system 0.2.10
  floki 0.32.1
  gettext 0.19.1
  html_assertion 0.1.5
  html_entities 0.5.2
  jason 1.3.0
  mime 2.0.2
  phoenix 1.6.2
  phoenix_ecto 4.4.0
  phoenix_html 3.2.0
  phoenix_live_dashboard 0.6.5
  phoenix_live_reload 1.3.3
  phoenix_live_view 0.17.10
  phoenix_pubsub 2.0.0
  phoenix_view 1.0.0
  plug 1.12.1
  plug_cowboy 2.5.2
  plug_crypto 1.2.2
  postgrex 0.16.5
  ranch 1.8.0
  swoosh 1.7.1
  telemetry 1.0.0
  telemetry_metrics 0.6.1
  telemetry_poller 1.0.0
...
```


config/dev.exs
```elixir
import Config

# + >>>
defmodule Credentials do
  @doc """
  fetch password from ~/.pgpass for a given username
  """
  def fetch_pass_from_pgpass(username) do
    filename = Path.join(System.get_env("HOME"), ".pgpass")

    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.find_value(nil, fn line ->
      case line do
        "#" <> _rest -> # comment
            nil
        line ->
          case String.split(line, ":") do
            [_,_,_, ^username, password] -> password # Return password if matched
            _ -> nil
          end
      end
    end)
  end
end


# Configure your database
config :sample_app, SampleApp.Repo,
  # username: "postgres",                                   # -
  # password: "postgres",                                   # -
  username: "dbuser",                                       # +
  password: Credentials.fetch_pass_from_pgpass("dbuser"),   # +
  database: "sample_app_dev",
  # ...
```
