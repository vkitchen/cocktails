module Msg exposing (Msg(..))

import Http
import Types exposing (..)

type Msg
  = UpdateIndex (Result Http.Error (List DrinkPath))
  | UpdatePage (Result Http.Error Drink)
  | ChangePage String
