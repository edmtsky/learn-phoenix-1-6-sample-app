defmodule SampleApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:name, :email, :password, :password_confirmation]
  @valid_email_regex ~r/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    timestamps()
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, message: "does not match password")
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

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
end
