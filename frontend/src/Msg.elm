module Msg exposing (Msg(..))

{-| Messages which may be sent around to trigger behaviour.
-}

import Page.Drink as Drink
import Page.Errored exposing (PageLoadError)
import Page.Home as Home
import Page.Search as Search
import Route exposing (Route)


type Msg
  = SetRoute (Maybe Route)
  | UpdateUrl Route
  | UpdateQuery String
  | HomeLoaded (Result PageLoadError Home.Model)
  | DrinkLoaded (Result PageLoadError Drink.Model)
  | SearchLoaded (Result PageLoadError Search.Model)
  | HomeMsg Home.Msg
  | DrinkMsg Drink.Msg
  | SearchMsg Search.Msg
