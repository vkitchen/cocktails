module Request.Index exposing (index)

import Data.Drink as Drink exposing (Drink)
import Http
import Json.Decode as Decode
import Request.Helpers exposing (apiUrl)


-- INDEX --


index : Http.Request (List Drink)
index =
  Decode.list Drink.drinkDecoder
    |> Http.get (apiUrl "/drinks.json")
