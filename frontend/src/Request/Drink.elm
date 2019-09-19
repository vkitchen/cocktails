module Request.Drink exposing (drink)

import Data.Drink as Drink exposing (Drink)
import Http exposing (encodeUri)
import Json.Decode as Decode
import Request.Helpers exposing (apiUrl)


-- INDEX --


drink : String -> Http.Request Drink
drink slug =
  Drink.drinkDecoder
    |> Http.get (apiUrl ("/drinks/" ++ (encodeUri slug) ++ ".json"))
