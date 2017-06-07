module Request.Index exposing (index)

import Data.Index as Index exposing (DrinkPath)
import Http
import Json.Decode as Decode
import Request.Helpers exposing (apiUrl)


-- INDEX --


index : Http.Request (List DrinkPath)
index =
  Decode.list Index.drinkPathDecoder
    |> Http.get (apiUrl "/index")
