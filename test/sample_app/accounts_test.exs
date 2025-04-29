defmodule SampleApp.AccountsTest do
  use SampleApp.DataCase

  alias SampleApp.Accounts

  describe "users" do
    alias SampleApp.Accounts.User

    import SampleApp.AccountsFixtures

    @invalid_attrs %{email: nil, name: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()

      user2 = user_fixture(%{email: "email2@example.com"})

      assert Accounts.list_users() == [user, user2]
    end

    # describe "get_user!/1" do
    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
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
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    # assert %User{} = Accounts.get_user(user.id)
    test "get_user/1 returns nil if the user is not found" do
      invalid_user_id = 111
      assert Accounts.get_user(invalid_user_id) == nil
    end

    # end

    test "get_user_by/1 returns the user with given email field" do
      # {:ok, %User{email: email}} = Accounts.create_user(@valid_attrs)
      %User{email: email} = user_fixture()
      assert %User{email: ^email} = Accounts.get_user_by(email: email)
    end

    test "get_user_by/1 returns nil if the user is not found" do
      invalid_user_email = "doesnotexist@example.com"
      assert nil == Accounts.get_user_by(email: invalid_user_email)
    end

    test "get_user_by!/1 returns the user with given email field" do
      %User{email: email} = user_fixture()
      assert %User{email: ^email} = Accounts.get_user_by!(email: email)
    end

    test "get_user_by!/1 raises Ecto.NoResultsError if the user is not found" do
      invalid_user_email = "doesnotexist@example.com"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by!(email: invalid_user_email)
      end
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "some email", name: "some name"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 name left blank does not insert user" do
      bad_user_attrs = %{email: "some email", name: "      "}

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(bad_user_attrs)
    end

    test "create_user/1 email left blank does not insert user" do
      bad_user_attrs = %{email: "   ", name: "some name"}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(bad_user_attrs)
    end

    test "create_user/1 name too long does not insert user" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 email: "some email",
                 name: String.duplicate("a", 51)
               })
    end

    test "create_user/1 email too long does not insert user" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 name: "some name",
                 email: String.duplicate("a", 244) <> "@example.com"
               })
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "some updated email", name: "some updated name"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
      assert Repo.get(User, user.id) == nil
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
