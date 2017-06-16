module Main exposing (main)

import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Navigation exposing (Location)
import Page.Drink as Drink
import Page.Errored as Errored exposing (PageLoadError)
import Page.Home as Home
import Page.NotFound as NotFound
import Page.Search as Search
import Ports
import Progress
import Route exposing (Route)
import Task
import Views.Frame as Frame


(=>) =
  (,)


type Page
  = Blank
  | NotFound
  | Errored PageLoadError
  | Home Home.Model
  | Drink Drink.Model
  | Search Search.Model


type PageState
  = Displaying Page Route
  | Loaded Page Route Bool Page Route
  | Transitioning Page Route Bool Route


type alias Model =
  { pageState : PageState
  , frameState : Frame.State
  , progress : Progress.State
  }


init : Location -> ( Model, Cmd Msg )
init location =
  uriUpdate (Route.fromLocation location)
    { pageState = Displaying Blank Route.None
    , frameState = Frame.init
    , progress = Progress.init
    }



-- VIEW --

progressConfig : Progress.Config Msg
progressConfig =
  Progress.config
    { toMsg = UpdateProgress
    , toLoaded = ProgressDone
    }


pageConfig : Frame.Config Msg
pageConfig =
  Frame.config
    { changePage = ChangePage
    , updateState = UpdateFrameState
    }


homeConfig : Home.Config Msg
homeConfig =
  Home.config
    { changePage = ChangePage
    , toMsg = HomeMsg
    }


drinkConfig : Drink.Config Msg
drinkConfig =
  Drink.config
    { changePage = ChangePage
    , toMsg = DrinkMsg
    }


searchConfig : Search.Config Msg
searchConfig =
  Search.config
    { changePage = ChangePage
    , toMsg = SearchMsg
    }


view : Model -> Html Msg
view model =
  let
    page = getPage model.pageState

    progressBar =
      Progress.view progressConfig model.progress

    frame = Frame.frame progressBar pageConfig model.frameState
  in
  frame <|
    case page of
      NotFound ->
        NotFound.view

      Blank ->
        Html.text ""

      Errored subModel ->
        Errored.view subModel

      Home subModel ->
        Home.view homeConfig subModel

      Drink subModel ->
        Drink.view drinkConfig subModel

      Search subModel ->
        Search.view searchConfig subModel


-- UPDATE --


type Msg
  = ChangePage Route
  | UriUpdate Route
  | UpdateProgress
  | ProgressDone
  | UpdateFrameState Frame.State
  | HomeLoaded (Result PageLoadError Home.Model)
  | DrinkLoaded Route (Result PageLoadError Drink.Model)
  | SearchLoaded Route (Result PageLoadError Search.Model)
  | HomeMsg Home.Msg
  | DrinkMsg Drink.Msg
  | SearchMsg Search.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> (Model, Cmd Msg)
updatePage page msg model =
    let
      toPage toModel toMsg subUpdate subMsg subModel =
        let
          (newModel, newCmd) =
            subUpdate subMsg subModel
        in
        case model.pageState of
          Displaying page route ->
            { model | pageState = Displaying (toModel newModel) route} => Cmd.map toMsg newCmd

          Transitioning page route history toRoute ->
            { model | pageState = Transitioning (toModel newModel) route history toRoute } => Cmd.map toMsg newCmd

          Loaded page route history toPage toRoute ->
            { model | pageState = Loaded (toModel newModel) route history toPage toRoute } => Cmd.map toMsg newCmd
    in
    case (msg, page) of
      -- Internally triggered
      (ChangePage newRoute, _) ->
        case model.pageState of
          Displaying page route ->
            if newRoute /= route then
              { model | pageState = Transitioning page route True newRoute, progress = Progress.start } => Cmd.batch [ loadRoute newRoute, Route.newUrl newRoute ]
            else
              -- user wants a page refresh (don't add to history)
              { model | pageState = Transitioning page route False newRoute, progress = Progress.start } => loadRoute newRoute

          Transitioning page route history toRoute ->
            if newRoute /= toRoute then
              { model | pageState = Transitioning page route True newRoute, progress = Progress.start }
              => Cmd.batch
                  [ loadRoute newRoute
                  , if history then
                      Route.modifyUrl newRoute
                    else
                      Route.newUrl newRoute
                  ]
            else
              -- user probably double clicked
              model => Cmd.none

          Loaded page route history _ toRoute ->
            if newRoute /= toRoute then
              { model | pageState = Transitioning page route True newRoute, progress = Progress.start }
              => Cmd.batch
                  [ loadRoute newRoute
                  , if history then
                      Route.modifyUrl newRoute
                    else
                      Route.newUrl newRoute
                  ]
            else
              -- user probably double clicked
              model => Cmd.none

      -- Uri changed on us (often as a response of ChangePage)
      (UriUpdate newRoute, _) ->
        uriUpdate newRoute model

      (UpdateProgress, _) ->
        { model | progress = Progress.update model.progress } => Cmd.none

      (ProgressDone, _) ->
        case model.pageState of
          Loaded _ _ _ page route ->
            { model | pageState = Displaying page route, progress = Progress.init, frameState = Frame.updateSearch route model.frameState } => Cmd.none

          _ ->
            model => Cmd.none

      (UpdateFrameState newState, _) ->
        { model | frameState = newState } => Cmd.none

      (HomeLoaded (Ok subModel), _) ->
        case model.pageState of
          Transitioning page route history Route.Home ->
            { model | pageState = Loaded page route history (Home subModel) Route.Home, progress = Progress.done model.progress } => Cmd.none

          _ ->
            model => Cmd.none

      (HomeLoaded (Err error), _) ->
        case model.pageState of
          Transitioning page route history Route.Home ->
            { model | pageState = Loaded page route history (Errored error) Route.Home, progress = Progress.done model.progress } => Cmd.none

          _ ->
            model => Cmd.none

      (DrinkLoaded route (Ok subModel), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Drink subModel) toRoute, progress = Progress.done model.progress } => Cmd.none
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (DrinkLoaded route (Err error), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Errored error) toRoute, progress = Progress.done model.progress } => Cmd.none
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (SearchLoaded route (Ok subModel), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Search subModel) toRoute, progress = Progress.done model.progress } => Cmd.none
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (SearchLoaded route (Err error), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Errored error) toRoute, progress = Progress.done model.progress } => Cmd.none
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (HomeMsg subMsg, Home subModel) ->
        toPage Home HomeMsg Home.update subMsg subModel

      (DrinkMsg subMsg, Drink subModel) ->
        toPage Drink DrinkMsg Drink.update subMsg subModel

      (SearchMsg subMsg, Search subModel) ->
        toPage Search SearchMsg Search.update subMsg subModel

      ( _, _ ) ->
        -- Disregard incoming messages that arrived for the wrong page
        model => Cmd.none


getPage : PageState -> Page
getPage pageState =
  case pageState of
    Displaying page _ ->
      page

    Transitioning page _ _ _ ->
      page

    Loaded page _ _ _ _ ->
      page


getToRoute : PageState -> Route
getToRoute pageState =
  case pageState of
    Displaying _ _ ->
      Route.None

    Transitioning _ _ _ toRoute ->
      toRoute

    Loaded _ _ _ _ toRoute ->
      toRoute


loadRoute : Route -> Cmd Msg
loadRoute route =
  case route of
    Route.None ->
      Cmd.none

    Route.Home ->
      Task.attempt HomeLoaded Home.init

    Route.Drink slug ->
      Task.attempt (DrinkLoaded route) (Drink.init slug)

    Route.Search slug ->
      Task.attempt (SearchLoaded route) (Search.init slug)


-- needs to be called by init as well as update
uriUpdate : Route -> Model -> ( Model, Cmd Msg )
uriUpdate newRoute model =
  case model.pageState of
    Displaying page route ->
      if newRoute /= route then
        { model | pageState = Transitioning page route False newRoute, progress = Progress.start } => loadRoute newRoute
      else
        model => Cmd.none

    Transitioning page route history toRoute ->
      if newRoute == route then
        -- user likely hit back. "finish" loading
        { model | pageState = Loaded page route history page route, progress = Progress.done model.progress } => Cmd.none
      else if newRoute /= toRoute then
        { model | pageState = Transitioning page route history newRoute, progress = Progress.start } => loadRoute newRoute
      else
        model => Cmd.none

    Loaded page route history _ toRoute ->
      if newRoute == route then
        -- user likely hit back. "finish" loading
        { model | pageState = Loaded page route history page route, progress = Progress.done model.progress } => Cmd.none
      else if newRoute /= toRoute then
        { model | pageState = Transitioning page route history newRoute, progress = Progress.start } => loadRoute newRoute
      else
         model => Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
  Progress.subscriptions progressConfig model.progress


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> UriUpdate)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
