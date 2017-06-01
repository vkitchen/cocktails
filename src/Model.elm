module Model exposing (Model, init, getPage)

import Http
import Json.Decode as Decode
import Msg exposing (Msg)
import Task
import Types exposing (..)

type alias Model =
  { url : String
  , index : List DrinkPath
  , drink : Maybe Drink
  }

init : ( Model, Cmd Msg )
init =
  ( Model "index" [] Nothing, getPage "/index.json" )


getPage : String -> Cmd Msg
getPage url =
  if url == "/index.json" then
    Http.send Msg.UpdateIndex (Http.get url decodeIndex)
  else
    Http.send Msg.UpdatePage (Http.get url decodePage)

decodeIndex : Decode.Decoder (List DrinkPath)
decodeIndex =
  Decode.list
    <| Decode.map2 DrinkPath
        (Decode.field "file" Decode.string)
        (Decode.field "name" Decode.string)

decodePage : Decode.Decoder Drink
decodePage =
  Decode.map8 Drink
    (Decode.field "name" Decode.string)
    (Decode.field "IBA" Decode.bool)
    (Decode.field "class" Decode.string)
    (Decode.field "serve" Decode.string)
    (Decode.field "garnish" (Decode.list Decode.string))
    (Decode.field "drinkware" Decode.string)
    (Decode.field "ingredients" (Decode.list decodeIngredients))
    (Decode.field "method" Decode.string)

decodeIngredients : Decode.Decoder DrinkIngredient
decodeIngredients =
  Decode.map3 DrinkIngredient
    (Decode.field "name" Decode.string)
    (Decode.field "measure" Decode.string)
    (Decode.field "unit" Decode.string)
