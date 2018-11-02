defmodule BayberryWeb.Main.IndexTest do
  import BayberryWeb.Router.Helpers
  use BayberryWeb.ConnCase
  use Hound.Helpers
  alias BayberryWeb.Endpoint

  hound_session()

  setup do
    Endpoint
    |> main_url(:index)
    |> navigate_to

    :ok
  end

  @tag acceptance: true
  test "main page" do
    assert page_source() =~ "Data Punnet"
    assert page_source() =~ "Site Architecture"
    assert page_source() =~ "Digit Recognition"
    assert page_source() =~ "Word Association"
    assert page_source() =~ "Twitter Stream"
    assert page_source() =~ "Blog"
  end

  @tag acceptance: true
  test "architecture page" do
    link = find_element(:link_text, "Site Architecture")
    click(link)

    assert current_url() == main_url(Endpoint, :architecture)
  end

  @tag acceptance: true
  test "digit recognition page" do
    link = find_element(:link_text, "Digit Recognition")
    click(link)

    assert current_url() == main_url(Endpoint, :mnist)
  end

  @tag acceptance: true
  test "word association page" do
      link = find_element(:link_text, "Word Association")
    click(link)

    assert current_url() == main_url(Endpoint, :nlp)
  end

  @tag acceptance: true
  test "twitter stream page" do
    link = find_element(:link_text, "Twitter Stream")
    click(link)

    assert current_url() == main_url(Endpoint, :twitter)
  end

  @tag acceptance: true
  test "blog page" do
    link = find_element(:link_text, "Blog")
    click(link)

    assert current_url() == blog_article_url(Endpoint, :posts)
  end
end
