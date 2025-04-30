defmodule SampleApp.AccountsTest do
  use SampleApp.DataCase

  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleApp.Factory

  describe "users" do
    @valid_attrs %{
      name: "Example User",
      email: "user@example.com",
      password: "secret",
      password_confirmation: "secret"
    }
    @invalid_attrs %{
      email: nil,
      name: nil,
      password: nil,
      password_confirmation: nil
    }

    test "list_users/0 returns all users" do
      %User{id: id1} = Factory.insert(:user)
      %User{id: id2} = Factory.insert(:user)

      assert [%User{id: ^id1}, %User{id: ^id2}] = Accounts.list_users()
    end

    # describe "get_user!/1" do
    test "get_user!/1 returns the user with given id" do
      %User{id: id} = Factory.insert(:user)
      assert %User{id: ^id} = Accounts.get_user!(id)
    end

    test "get_user!/1 returns nil if the user is not found" do
      invalid_user_id = 111

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(invalid_user_id)
      end
    end

    # end

    # describe "get_user/1" do
    test "get_user/1 returns the user with given id" do
      %User{id: id} = Factory.insert(:user)
      assert %User{id: ^id} = Accounts.get_user(id)
    end

    # assert %User{} = Accounts.get_user(user.id)
    test "get_user/1 returns nil if the user is not found" do
      invalid_user_id = 111
      assert Accounts.get_user(invalid_user_id) == nil
    end

    # end

    test "get_user_by/1 returns the user with given email field" do
      # {:ok, %User{email: email}} = Accounts.create_user(@valid_attrs)
      %User{email: email} = Factory.insert(:user)
      assert %User{email: ^email} = Accounts.get_user_by(email: email)
    end

    test "get_user_by/1 returns nil if the user is not found" do
      invalid_user_email = "doesnotexist@example.com"
      assert nil == Accounts.get_user_by(email: invalid_user_email)
    end

    test "get_user_by!/1 returns the user with given email field" do
      %User{email: email} = Factory.insert(:user)
      assert %User{email: ^email} = Accounts.get_user_by!(email: email)
    end

    test "get_user_by!/1 raises Ecto.NoResultsError if the user is not found" do
      invalid_user_email = "doesnotexist@example.com"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by!(email: invalid_user_email)
      end
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "user@example.com"
      assert user.name == "Example User"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 name left blank does not insert user" do
      bad_user_attrs = %{@valid_attrs | name: "      "}

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(bad_user_attrs)
    end

    test "create_user/1 email left blank does not insert user" do
      bad_user_attrs = %{@valid_attrs | email: "      "}

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(bad_user_attrs)
    end

    test "create_user/1 name too long does not insert user" do
      bad_user_attrs = %{@valid_attrs | name: String.duplicate("a", 51)}

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(bad_user_attrs)
    end

    test "create_user/1 email too long does not insert user" do
      long_email = String.duplicate("a", 244) <> "@example.com"
      bad_user_attrs = %{@valid_attrs | email: long_email}

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(bad_user_attrs)
    end

    test "create_user/1 valid email addresses insert user" do
      valid_addresses = [
        "user@example.com",
        "USER@foo.COM",
        "A_US-ER@foo.bar.org",
        "first.last@foo.jp",
        "alice+bob@baz.cn"
      ]

      for valid_address <- valid_addresses do
        assert {:ok, %User{}} =
                 Accounts.create_user(%{
                   @valid_attrs
                   | email: valid_address
                 })
      end
    end

    test "create_user/1 invalid email addresses do not insert user" do
      invalid_addresses = [
        "user@example,com",
        "user_at_foo.org",
        "user.name@example.",
        "foo@bar_baz.com",
        "foo@bar+baz.com"
      ]

      for invalid_address <- invalid_addresses do
        assert {:error, %Ecto.Changeset{}} =
                 Accounts.create_user(%{
                   @valid_attrs
                   | email: invalid_address
                 })
      end
    end

    test "create_user/1 existing email address does not insert user" do
      Factory.insert(:user, @valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | email: String.upcase(@valid_attrs.email)
               })
    end

    test "create_user/1 email address is inserted as lower-case" do
      mixed_case_email = "Foo@ExAMPle.CoM"

      assert {:ok, %User{email: "foo@example.com"}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | email: mixed_case_email
               })
    end

    test "create_user/1 password left blank does not insert user" do
      blank_password = String.duplicate(" ", 6)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | password: blank_password,
                   password_confirmation: blank_password
               })
    end

    test "create_user/1 password too short does not insert user" do
      short_password = String.duplicate("a", 5)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | password: short_password,
                   password_confirmation: short_password
               })
    end

    test "update_user/2 with valid data updates the user" do
      user = Factory.insert(:user)

      update_attrs = %{
        email: "some-updated@email.com",
        name: "some updated name",
        password: "secret2",
        password_confirmation: "secret2"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.email == "some-updated@email.com"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = %User{id: id} = Factory.insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = Factory.insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
      assert Repo.get(User, user.id) == nil
    end

    test "change_user/1 returns a user changeset" do
      user = Factory.insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "authenticate_by_email_and_pass/2" do
    @email "user@example.com"
    @password "123456"

    setup do
      {:ok,
       user:
         Factory.insert(:user,
           email: @email,
           password: @password,
           password_hash: Argon2.hash_pwd_salt(@password)
         )}
    end

    test "returns user with correct password", %{user: %User{id: id}} do
      res = Accounts.authenticate_by_email_and_pass(@email, @password)
      assert {:ok, %User{id: ^id}} = res
    end

    test "returns unauthorized error with invalid password" do
      assert {:error, :unauthorized} =
               Accounts.authenticate_by_email_and_pass(@email, "badpassword")
    end

    test "returns not found error with no matching user for email" do
      assert {:error, :not_found} =
               Accounts.authenticate_by_email_and_pass("bad@email.com", @pass)
    end
  end
end
