module Data.Index exposing (DrinkPath, drinkPathDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias DrinkPath =
  { file : String
  , name : String
  }


drinkPathDecoder : Decoder DrinkPath
drinkPathDecoder =
  Decode.map2 DrinkPath
    (Decode.field "file" Decode.string)
    (Decode.field "name" Decode.string)
