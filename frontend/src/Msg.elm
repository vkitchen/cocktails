module Msg exposing (Msg(..))

{-| Messages which may be sent around to trigger behaviour.
-}

import Page.Drink as Drink
import Page.Errored exposing (PageLoadError)
import Page.Home as Home
import Route exposing (Route)


type Msg
    = SetRoute (Maybe Route)
    | UpdateUrl Route
    | HomeLoaded (Result PageLoadError Home.Model)
    | DrinkLoaded (Result PageLoadError Drink.Model)
    | HomeMsg Home.Msg
    | DrinkMsg Drink.Msg
