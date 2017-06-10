module Model exposing (Page(..), PageState(..), Model)

{-| State which is shared throughout the application.
-}

import Page.Drink as Drink
import Page.Errored exposing (PageLoadError)
import Page.Home as Home
import Page.Search as Search


type Page
  = Blank
  | NotFound
  | Errored PageLoadError
  | Home Home.Model
  | Drink Drink.Model
  | Search Search.Model


type PageState
  = Loaded Page
  | TransitioningFrom Page


type alias Model =
  { pageState : PageState
  , query : String
  }
