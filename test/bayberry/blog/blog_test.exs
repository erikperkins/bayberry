defmodule Bayberry.BlogTest do
  use Bayberry.DataCase

  alias Bayberry.Blog

  @article_attrs %{body: "some body", title: "some title"}
  @author_attrs %{bio: "bio", role: "role", genre: "genre"}
  @user_attrs %{name: "name", username: "username"}
  @admin_attrs %{name: "admin", username: "admin"}

  setup do
    {:ok, admin} = Bayberry.Accounts.create_user(@admin_attrs)
    {:ok, user} = Bayberry.Accounts.create_user(@user_attrs)
    {:ok, author} = Blog.create_author(user, @author_attrs)
    {:ok, article_} = Blog.create_article(author, @article_attrs)
    article = %{article_ | views: 0 }

    {:ok, user: user, author: author, admin: admin, article: article}
  end

  describe "articles" do
    alias Bayberry.Blog.Article

    @valid_attrs %{body: "some body", title: "some title"}
    @update_attrs %{body: "some updated body", title: "some updated title"}
    @invalid_attrs %{body: nil, title: nil}

    test "list_articles/0 returns all articles", %{article: article} do
      articles = Blog.list_articles() |> Enum.map(fn a -> Ecto.Reaper.unload(a, :author) end)
      assert articles == [article]
    end

    test "get_article!/1 returns the article with given id", %{article: article} do
      assert article == Blog.get_article!(article.id) |> Ecto.Reaper.unload(:author)
    end

    test "create_article/1 with valid data creates a article", %{author: author} do
      assert {:ok, %Article{} = article} = Blog.create_article(author, @valid_attrs)
      assert article.body == "some body"
      assert article.title == "some title"
    end

    test "create_article/1 with invalid data returns error changeset", %{author: author} do
      assert {:error, %Ecto.Changeset{}} = Blog.create_article(author, @invalid_attrs)
    end

    test "update_article/2 with valid data updates the article", %{article: article} do
      assert {:ok, article} = Blog.update_article(article, @update_attrs)
      assert %Article{} = article
      assert article.body == "some updated body"
      assert article.title == "some updated title"
    end

    test "update_article/2 with invalid data returns error changeset", %{article: article} do
      assert {:error, %Ecto.Changeset{}} = Blog.update_article(article, @invalid_attrs)
      assert article == Blog.get_article!(article.id) |> Ecto.Reaper.unload(:author)
    end

    test "delete_article/1 deletes the article", %{article: article} do
      assert {:ok, %Article{}} = Blog.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset", %{article: article} do
      assert %Ecto.Changeset{} = Blog.change_article(article)
    end
  end

  describe "authors" do
    alias Bayberry.Blog.Author

    @valid_attrs %{bio: "some bio", genre: "some genre", role: "some role"}
    @update_attrs %{bio: "some updated bio", genre: "some updated genre", role: "some updated role"}
    @invalid_attrs %{bio: nil, genre: nil, role: nil}

    test "list_authors/0 returns all authors", %{author: author} do
      authors = Blog.list_authors() |> Enum.map(fn a -> Ecto.Reaper.unload(a, :user) end)
      assert authors == [author]
    end

    test "get_author!/1 returns the author with given id", %{author: author} do
      assert author == Blog.get_author!(author.id) |> Ecto.Reaper.unload(:user)
    end

    test "create_author/1 with valid data creates a author", %{admin: admin} do
      assert {:ok, %Author{} = author} = Blog.create_author(admin, @valid_attrs)
      assert author.bio == "some bio"
      assert author.genre == "some genre"
      assert author.role == "some role"
    end

    test "create_author/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Blog.create_author(user, @invalid_attrs)
    end

    test "update_author/2 with valid data updates the author", %{author: author} do
      assert {:ok, author} = Blog.update_author(author, @update_attrs)
      assert %Author{} = author
      assert author.bio == "some updated bio"
      assert author.genre == "some updated genre"
      assert author.role == "some updated role"
    end

    test "update_author/2 with invalid data returns error changeset", %{author: author} do
      assert {:error, %Ecto.Changeset{}} = Blog.update_author(author, @invalid_attrs)
      assert author == Blog.get_author!(author.id) |> Ecto.Reaper.unload(:user)
    end

    test "delete_author/1 deletes the author", %{author: author} do
      assert {:ok, %Author{}} = Blog.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset", %{author: author} do
      assert %Ecto.Changeset{} = Blog.change_author(author)
    end
  end
end
