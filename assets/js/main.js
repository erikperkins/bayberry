import {Architecture} from "./main/architecture"
import {Digits} from "./main/digits"
import {Topics} from "./main/topics"
import {TweetyBird} from "./main/tweetybird"
import {Visitors} from "./main/visitors"
import {WordCloud} from "./main/wordcloud"

let placards = [
  Architecture,
  Digits,
  Topics,
  TweetyBird,
  WordCloud,
  Visitors
]

for (const [i, placard] of placards.entries()) {
  let timeout = 1000 * Math.asinh(i)
  setTimeout(placard.run, timeout)
}
