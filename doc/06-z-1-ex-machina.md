# package ExMachina (ex_machina) what is it? and usage cases and examples.


ExMachina is an Elixir library designed for building and using factories for
creating test data. It helps developers generate data structures that can be
used in tests, making it easier to set up the context required for various
tests without having to write repetitive code.

### Key Features:

1. **Declarative Factories**:
   You can define schemas and their associated data fields in a concise and
   readable manner.

2. **Customizable Data**:
   Easily override default attributes when generating instances of your data.

3. **Support for Associations**:
   Automatically create related records when building complex structures,
   especially useful for `Ecto` schemas.

### Usage Cases:

1. **Testing with Ecto**:
   When working with databases through Ecto,
   ExMachina simplifies the creation of model instances for use in tests,
   allowing for the rapid setup of test cases.

2. **Generating Mock Data**:
   It helps in generating realistic data for tests
   without resorting to hardcoding values or manually creating data.

3. **Enhancing Readability**:
   Factories can make tests cleaner and more expressive,
   improving the readability of your test suite.

4. **Speeding Up Test Setup**:
   It reduces the boilerplate code needed to set up test conditions,
   allowing developers to focus more on the logic being tested.


### Installation

To use ExMachina in your Elixir project, you can add it to your `mix.exs`
dependencies:

```elixir
defp deps do
  [
    {:ex_machina, "~> 2.7", only: :test}
  ]
end
```

Then run:
```bash
mix deps.get
```

### Example Usage:

Here's a simple example of how to use ExMachina
to set up a factory for a hypothetical `User` schema defined in Ecto.

1. **Define a Factory**:

```elixir
# lib/my_app/factories.ex
defmodule MyApp.Factories do
  use ExMachina.Ecto, repo: MyApp.Repo

  def user_factory do
    %MyApp.User{
      name: "John Doe",
      email: sequence(:email, &"user#{&1}@example.com"),
      password: "secret_password"
    }
  end
end
```

2. **Integrate Factories in Tests**:

You can then use this factory in your test cases:

```elixir
# test/my_app/user_test.exs
defmodule MyApp.UserTest do
  use MyApp.DataCase
  import MyApp.Factories

  test "creating a user with valid attributes" do
    user = insert!(:user, name: "Jane Doe")

    assert user.name == "Jane Doe"
    assert user.email =~ ~r/user\d+@example\.com/
    assert user.password == "secret_password"
  end
end
```

3. **Customizing Factory Instances**:

When you need to create different variations of a user,
you can override default fields easily:

```elixir
test "creating a user with a specific email" do
  user = insert!(:user, email: "specific@example.com")

  assert user.email == "specific@example.com"
end
```


### Summary:

ExMachina is an efficient tool for generating test data in Elixir applications,
especially those using `Ecto`. It allows for the creation of reusable factories
that reduce boilerplate code and enhance test clarity and maintainability.
By providing a straightforward API for building test data, it significantly aids
developers in focusing more on the core logic of their applications.

