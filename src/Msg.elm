module Msg exposing (Msg(..))

import Http
import Navigation
import Types exposing (..)

type Msg
  = UrlChange Navigation.Location
  | UpdateIndex (Result Http.Error (List DrinkPath))
  | UpdatePage (Result Http.Error Drink)
