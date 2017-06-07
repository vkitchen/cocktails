module Data.Drink exposing (Drink, DrinkIngredient, drinkDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias DrinkIngredient =
  { name : String
  , measure : String
  , unit : String
  }


type alias Drink =
  { name : String
  , iba : Bool
  , class : String
  , serve : String
  , garnish : List String
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
    (Decode.field "IBA" Decode.bool)
    (Decode.field "class" Decode.string)
    (Decode.field "serve" Decode.string)
    (Decode.field "garnish" (Decode.list Decode.string))
    (Decode.field "drinkware" Decode.string)
    (Decode.field "ingredients" (Decode.list decodeIngredients))
    (Decode.field "method" Decode.string)
