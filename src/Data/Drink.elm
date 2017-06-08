module Data.Drink exposing (Drink, DrinkIngredient, drinkDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias DrinkIngredient =
  { name : String
  , measure : String
  , unit : String
  }


type alias Drink =
  { name : String
  , img : List String
  , lists : List String
  , serve : String
  , garnish : String
  , drinkware : String
  , ingredients : List DrinkIngredient
  , method : String
  }


decodeIngredients : Decode.Decoder DrinkIngredient
decodeIngredients =
  Decode.map3 DrinkIngredient
    (Decode.field "name" Decode.string)
    (Decode.field "measure" Decode.string)
    (Decode.field "unit" Decode.string)


-- PUBLIC HELPERS --


drinkDecoder : Decoder Drink
drinkDecoder =
  Decode.map8 Drink
    (Decode.field "name" Decode.string)
    (Decode.field "img" (Decode.list Decode.string))
    (Decode.field "lists" (Decode.list Decode.string))
    (Decode.field "serve" Decode.string)
    (Decode.field "garnish" Decode.string)
    (Decode.field "drinkware" Decode.string)
    (Decode.field "ingredients" (Decode.list decodeIngredients))
    (Decode.field "method" Decode.string)
