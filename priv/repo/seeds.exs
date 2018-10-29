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
alias Bayberry.{Accounts, Blog, Repo}
alias Bayberry.Administration.{Visit, Visitor}


admin_params = %{
  "name" => "administrator",
  "username" => "administrator",
  "credential" => %{
    "email" => "admin@datapun.net",
    "password" => "datapunnet"
  }
}

{:ok, user} = Accounts.create_user(admin_params)

author_params = %{
  "bio" => "admin",
  "role" => "admin",
  "genre" => "admin"
}

{:ok, author} = Blog.create_author(user, author_params)

article_params = %{
  "title" => "Test",
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

Blog.create_article(author, article_params)

visitor_params = %{
  "ip_address" => "66.249.64.0",
  "latitude" => 37.406000,
  "longitude" => -122.078500
}

{:ok, visitor} =
  %Visitor{}
  |> Visitor.changeset(visitor_params)
  |> Repo.insert()

visit_params = %{
  "path" => "/",
  "user_agent" => "Googlebot/2.1 (+http://www.google.com/bot.html)"
}

{:ok, visit} =
  %Visit{visitor: visitor}
  |> Visit.changeset(visit_params)
  |> Ecto.Changeset.cast_assoc(:visitor, with: &Visitor.changeset/2)
  |> Repo.insert()
