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


### Handle successful edit("Update your profile")

In order to provide users the ability to update their profile without entering a
password and password confirmation, you need to create additional changeset func:

create a new changeset function named `update_changeset` and
create a custom validates function named `validate_blank`

```elixir
defmodule SampleApp.Accounts do
  # ...

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)       # << to allow update without password
    |> Repo.update()
  end
```

```elixir
defmodule SampleApp.Accounts.User do
  # ...

  # when editing a user, we want users to be able to update their profile
  # without entering a password and password confirmation for convenience.
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :password,
      :password_confirmation
    ])
    |> validate_required([:name, :email])
    |> validate_blank([:password, :password_confirmation])
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, message: "does not match password")
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  # to validate for presence only on non-nil fields in User schema
  defp validate_blank(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      if get_change(changeset, field) == nil do
        changeset
      else
        validate_required(changeset, field)
      end
    end)
  end
```


### Authorization


#### Requiring logged-in users

Block attempt to edit users who have not logged-in.

requiring users to be logged-in when editing their profiles.
- add `AuthPlug.logged_in_user` - a plug function

```elixir
defmodule SampleAppWeb.AuthPlug do
  # ...
  import Phoenix.Controller                                                 # +
  alias SampleAppWeb.Router.Helpers, as: Routes                             # +

  # ...

  # function plug that confirms a logged-in user                            # +
  def logged_in_user(conn, _opts) do                                        # +
    if conn.assigns.current_user do                                         # +
      conn                                                                  # +
    else                                                                    # +
      conn                                                                  # +
      |> put_flash(:danger, "please log in.")                               # +
      |> redirect(to: Routes.login_path(conn, :create))                     # +
      |> halt()                                                             # +
    end                                                                     # +
  end                                                                       # +

  #...
end
```


- import the `AuthPlug.logged_in_user` function in `SampleAppWeb` module
  (so you can use it in all controllers)

- use AuthPlug.logged_in_user in UserController only for edit and update actions:


```elixir
defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  plug :logged_in_user when action in [:edit, :update]                     # +
  # ...

end
```
