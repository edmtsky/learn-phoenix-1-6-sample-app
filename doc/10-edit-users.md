update users

URL for a user's edit page(update profile) is `/users/1/edit` (See Table_7_1)
UserController.edit action

- add SampleAppWeb.UserController.edit action for (/users/1/edit)
- add title for DynamicTextHelper ("Edit profile")
- add lib/sample_app_web/templates/user/edit.html.heex
  (with using error_count_tag)
- update Settings link in lib/sample_app_web/templates/layout/_header.html.heex
  (add link in drop menu Accout -> Settings)

```heex
    <%= link "Settings",
      to: Routes.user_path(@conn, :edit, @current_user),
      class: "dropdown-item" %>
```

```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  # ...

  # action to send edit-form    <- Routes.user_path(@conn, :edit, @current_user)
  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  # to handle PUT /users/:id/edit from edit-form
  def update(conn, _params) do
    html(conn, "TODO")
  end
end
```


### target="_blank" + rel="noopener" for Gravatar

to fix a minor security issue associated with
using `target="_blank"` to open URLs, which is that
the target site gains control of what's known as the "window object"
associated with the HTML document.
The target site could potentially introduce malicious content,
such as a phishing page.

to eliminate this risk entirely - add `rel="noopener"` to the origin link.

```html
<a href="http://example.com" target="_blank" rel="noopener">
    some link
</a>
```

https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/rel/noopener
