defmodule SampleApp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SampleApp.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some@email.com",
        name: "some name",
        password: "secret",
        password_confirmation: "secret"
      })
      |> SampleApp.Accounts.create_user()

    user
  end
end
