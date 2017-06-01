module Msg exposing (Msg(..))

import Http
import Types exposing (..)

type Msg
  = NewPage (Result Http.Error (List Drink))
