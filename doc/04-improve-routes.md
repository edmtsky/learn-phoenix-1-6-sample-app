## add named routes

Route and URL mapping for site links.

|  Page   |   URL    | Named route
|---------|----------|--------------
| Home    | /        | root_path
| About   | /about   | about_path
| Help    | /help    | help_path
| Contact | /contact | contact_path
| Sign up | /signup  | signup_path
| Log in  | /login   | login_path


To add the named routes for the sample app's static pages,
by edit the router file(`lib/sample_app_web/router.ex`)
(This file Phoenix uses to define URL mappings)


```elixir
get "/", StaticPageController, :home, as: :root
#                                     ^^^^^^^^^
```
here using the `as: :root` option creates a named route `root_path`.
This distinguishes the root route when we call it like so:

```elixir
Routes.root_path(conn_or_endpoint, :home) -> "/"
```

using this this opportunity define shorter distinct named routes for
the `Help`, `About`, and `Contact` pages.

update the `get` rules from:

```elixir
get "/static_pages/help", StaticPageController, :help
```
to
```elixir
get "/help", StaticPageController, :help, as: :help
```

Like the rule for the `root` route, this creates the named route `help_path`:

```elixir
Routes.help_path(conn_or_endpoint, :help) -> "/help"
```

