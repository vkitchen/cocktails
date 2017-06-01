module Model exposing (Model, init)

import Msg exposing (Msg)
import Task
import Types exposing (..)

type alias Model =
  { frames : String }

init : ( Model, Cmd Msg )
init =
  ( Model "", Cmd.none )
