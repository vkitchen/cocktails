module Data.Drink exposing (Drink, DrinkIngredient, drinkDecoder, renderIngredient)

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


renderIngredient : DrinkIngredient -> String
renderIngredient ingredient =
  case (ingredient.measure, ingredient.unit) of
    ("0", "splash") ->
      ingredient.name

    ("1", "splash") ->
      "A splash of " ++ ingredient.name

    (_, "splash") ->
      ingredient.measure ++ " splashes " ++ ingredient.name

    ("0", "dash") ->
      ingredient.name

    ("1", "dash") ->
      "A dash of " ++ ingredient.name

    (_, "dash") ->
      ingredient.measure ++ " dashes " ++ ingredient.name

    ("0", "drop") ->
      ingredient.name

    ("1", "drop") ->
      "A drop of " ++ ingredient.name

    (_, "drop") ->
      ingredient.measure ++ " drops " ++ ingredient.name

    (_, "top") ->
      "Top with " ++ ingredient.name

    ("1", "taste") ->
      ingredient.name ++ " to taste"

    ("0", "none") ->
      ingredient.name

    ("1", "none") ->
      "A " ++ ingredient.name

    (_, "none") ->
      ingredient.measure ++ " " ++ ingredient.name

    (_, _) ->
      ingredient.measure ++ " " ++ ingredient.unit ++ " " ++ ingredient.name
