module Request.Search exposing (search)

import Data.Drink as Drink exposing (Drink)
import Http
import Json.Decode as Decode
import Request.Helpers exposing (apiUrl)


-- INDEX --


search : String -> Http.Request (List Drink)
search slug =
  Decode.list Drink.drinkDecoder
    |> Http.get (apiUrl ("/search/" ++ slug))
