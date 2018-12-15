# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bayberry.Repo.insert!(%Bayberry.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
require Logger
alias Bayberry.{Accounts, Blog, Repo}
alias Bayberry.Accounts.User
alias Bayberry.Administration.{Visit, Visitor}
alias Bayberry.Blog.{Article, Author}

admin_params = %{
  "name" => "administrator",
  "credential" => %{
    "email" => "admin@datapun.net",
    "password" => System.get_env("DATAPUNNET_ADMIN_PASSWORD")
  }
}

author_params = %{
  "bio" => "admin",
  "role" => "admin",
  "genre" => "admin"
}

lincoln_params = %{
  "title" => "Abraham Lincoln",
  "summary" => "The Gettysburg Address"
  "body" => """
  Four score and seven years ago our fathers brought forth on this continent,
  a new nation, conceived in Liberty, and dedicated to the proposition that all
  men are created equal. Now we are engaged in a great civil war, testing
  whether that nation, or any nation so conceived and so dedicated, can long
  endure. We are met on a great battle-field of that war. We have come to
  dedicate a portion of that field, as a final resting place for those who here
  gave their lives that that nation might live. It is altogether fitting and
  proper that we should do this. But, in a larger sense, we can not dedicate -
  we can not consecrate - we can not hallow - this ground. The brave men, living
  and dead, who struggled here, have consecrated it, far above our poor power to
  add or detract. The world will little note, nor long remember what we say here,
  but it can never forget what they did here. It is for us the living, rather,
  to be dedicated here to the unfinished work which they who fought here have
  thus far so nobly advanced. It is rather for us to be here dedicated to the
  great task remaining before us - that from these honored dead we take
  increased devotion to that cause for which they gave the last full measure of
  devotion - that we here highly resolve that these dead shall not have died in
  vain - that this nation, under God, shall have a new birth of freedom - and
  that government of the people, by the people, for the people, shall not
  perish from the earth.
  """
}

roosevelt_params = %{
  "title" => "Theodore Roosevelt",
  "summary" => "A quote from Theodore Rooselvelt"
  "body" => """
  It is not the critic who counts; not the man who points out how the strong
  man stumbles, or where the doer of deeds could have done them better. The
  credit belongs to the man who is actually in the arena, whose face is marred
  by dust and sweat and blood; who strives valiantly; who errs, who comes short
  again and again, because there is no effort without error and shortcoming;
  but who does actually strive to do the deeds; who knows great enthusiasms,
  the great devotions; who spends himself in a worthy cause; who at the best
  knows in the end the triumph of high achievement, and who at the worst, if he
  fails, at least fails while daring greatly, so that his place shall never be
  with those cold and timid souls who neither know victory nor defeat.
  """
}

visitor_params = %{
  "ip_address" => "66.249.64.0",
  "latitude" => 37.406000,
  "longitude" => -122.078500
}

visit_params = %{
  "path" => "/",
  "user_agent" => "Googlebot/2.1 (+http://www.google.com/bot.html)"
}

user =
  case Repo.get_by(User, name: admin_params["name"]) do
    nil ->
      {:ok, user} = Accounts.create_user(admin_params)
      user

    user ->
      Logger.warn("User already created")
      user
  end

author =
  case Repo.get_by(Author, bio: author_params["bio"]) do
    nil ->
      {:ok, author} = Blog.create_author(user, author_params)
      author

    author ->
      Logger.warn("Author already created")
      author
  end

case Repo.get_by(Article, title: lincoln_params["title"]) do
  nil ->
    {:ok, article} = Blog.create_article(author, lincoln_params)
    article

  article ->
     Logger.warn("Article already created")
    article
end

case Repo.get_by(Article, title: roosevelt_params["title"]) do
  nil ->
    {:ok, article} = Blog.create_article(author, roosevelt_params)
    article

  article ->
     Logger.warn("Article already created")
    article
end

visitor =
  case Repo.get_by(Visitor, ip_address: visitor_params["ip_address"]) do
    nil ->
      %Visitor{}
      |> Visitor.changeset(visitor_params)
      |> Repo.insert!()

    visitor ->
      Logger.warn("Visitor already created")
      visitor
  end

case Repo.get_by(Visit, user_agent: visit_params["user_agent"]) do
  nil ->
    %Visit{}
    |> Visit.changeset(visit_params)
    |> Ecto.Changeset.put_change(:visitor_id, visitor.id)
    |> Repo.insert!()

  _ ->
    Logger.warn("Visit already created")
end
