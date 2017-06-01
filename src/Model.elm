module Model exposing (Model, init)

import Http
import Json.Decode as Decode
import Msg exposing (Msg)
import Task
import Types exposing (..)

type alias Model =
  { page : String
  , drinks : List Drink
  }

init : ( Model, Cmd Msg )
init =
  ( Model "index" [], getPage "index" )


getPage : String -> Cmd Msg
getPage topic =
  let
    url =
      "/" ++ topic ++ ".json"
  in
    Http.send Msg.NewPage (Http.get url decodePage)

decodePage : Decode.Decoder (List Drink)
decodePage =
  Decode.list
    <| Decode.map2 Drink
        (Decode.field "file" Decode.string)
        (Decode.field "name" Decode.string)
