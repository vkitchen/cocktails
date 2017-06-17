module Main exposing (main)

import Defer
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import LruCache as Lru
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
  | NotFound Int
  | Errored Int PageLoadError
  | Home Int Home.Model
  | Drink Int Drink.Model
  | Search Int Search.Model


type PageState
  = Displaying Page Route
  | Loaded Page Route Bool Page Route
  | Transitioning Page Route Bool Route


type alias Model =
  { pageState : PageState
  , frameState : Frame.State
  , progress : Progress.State
  , bfcache : Lru.LruCache String Page
  , defer : Defer.Model
  }


init : Location -> ( Model, Cmd Msg )
init location =
  uriUpdate (Route.fromLocation location)
    { pageState = Displaying Blank Route.None
    , frameState = Frame.init
    , progress = Progress.init
    , bfcache = Lru.empty 5
    , defer = Defer.init []
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
      NotFound _ ->
        NotFound.view

      Blank ->
        Html.text ""

      Errored _ subModel ->
        Errored.view subModel

      Home _ subModel ->
        Home.view homeConfig subModel

      Drink _ subModel ->
        Drink.view drinkConfig subModel

      Search _ subModel ->
        Search.view searchConfig subModel


-- UPDATE --


type Msg
  = ChangePage Route
  | UriUpdate Route
  | UpdateProgress
  | ProgressDone
  | UpdateFrameState Frame.State
  | Scroll Int
  | DeferMsg Defer.Msg
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
          Loaded fromPage fromRoute _ page route ->
            { model
            | pageState = Displaying page route, progress = Progress.init
            , frameState = Frame.updateSearch route model.frameState
            , bfcache = Lru.insert (Route.toString fromRoute) fromPage model.bfcache
            } => Cmd.none

          _ ->
            model => Cmd.none

      (UpdateFrameState newState, _) ->
        { model | frameState = newState } => Cmd.none

      (Scroll newScroll, page) ->
        case model.pageState of
          Displaying page route ->
            { model | pageState = Displaying (scrollPage newScroll page) route } => Cmd.none

          Transitioning fromPage fromRoute history toRoute ->
            { model | pageState = Transitioning (scrollPage newScroll fromPage) fromRoute history toRoute } => Cmd.none

          Loaded fromPage fromRoute history toPage toRoute ->
            { model | pageState = Loaded (scrollPage newScroll fromPage) fromRoute history toPage toRoute } => Cmd.none

      (DeferMsg deferMsg, _) ->
        let
          (deferModel, deferCmd) = Defer.update deferMsg model.defer
        in
        { model | defer = deferModel } ! [ Cmd.map DeferMsg deferCmd ]

      (HomeLoaded (Ok subModel), _) ->
        case model.pageState of
          Transitioning page route history Route.Home ->
            { model | pageState = Loaded page route history (Home 0 subModel) Route.Home, progress = Progress.done model.progress } => Ports.title (Home.title subModel ++ " - Tophat")

          _ ->
            model => Cmd.none

      (HomeLoaded (Err error), _) ->
        case model.pageState of
          Transitioning page route history Route.Home ->
            { model | pageState = Loaded page route history (Errored 0 error) Route.Home, progress = Progress.done model.progress } => Ports.title "Loading Error - Tophat"

          _ ->
            model => Cmd.none

      (DrinkLoaded route (Ok subModel), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Drink 0 subModel) toRoute, progress = Progress.done model.progress } => Ports.title (Drink.title subModel ++ " - Tophat")
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (DrinkLoaded route (Err error), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Errored 0 error) toRoute, progress = Progress.done model.progress } => Ports.title "Loading Error - Tophat"
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (SearchLoaded route (Ok subModel), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Search 0 subModel) toRoute, progress = Progress.done model.progress } => Ports.title (Search.title subModel ++ " - Tophat")
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (SearchLoaded route (Err error), _) ->
        case model.pageState of
          Transitioning page fromRoute history toRoute ->
            if route == toRoute then
              { model | pageState = Loaded page fromRoute history (Errored 0 error) toRoute, progress = Progress.done model.progress } => Ports.title "Loading Error - Tophat"
            else
              model => Cmd.none

          _ ->
            model => Cmd.none

      (HomeMsg subMsg, Home scroll subModel) ->
        toPage (Home scroll) HomeMsg Home.update subMsg subModel

      (DrinkMsg subMsg, Drink scroll subModel) ->
        toPage (Drink scroll) DrinkMsg Drink.update subMsg subModel

      (SearchMsg subMsg, Search scroll subModel) ->
        toPage (Search scroll) SearchMsg Search.update subMsg subModel

      ( _, _ ) ->
        -- Disregard incoming messages that arrived for the wrong page
        model => Cmd.none


scrollPage : Int -> Page -> Page
scrollPage scroll page =
  case page of
    Blank ->
      Blank

    NotFound _ ->
      NotFound scroll

    Errored _ subModel ->
      Errored scroll subModel

    Home _ subModel ->
      Home scroll subModel

    Drink _ subModel ->
      Drink scroll subModel

    Search _ subModel ->
      Search scroll subModel


getScroll : Page -> Int
getScroll page =
  case page of
    Blank ->
      0

    NotFound scroll ->
      scroll

    Errored scroll _ ->
      scroll

    Home scroll _ ->
      scroll

    Drink scroll _ ->
      scroll

    Search scroll _ ->
      scroll


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
  let
    (_, cachedPage) = Lru.get (Route.toString newRoute) model.bfcache
  in
  case model.pageState of
    Displaying fromPage route ->
      if newRoute /= route then
        -- try to get from cache
        case cachedPage of
          Nothing ->
            { model | pageState = Transitioning fromPage route False newRoute, progress = Progress.start } => loadRoute newRoute

          Just toPage ->
            { model
            | pageState = Displaying toPage newRoute
            , bfcache = Lru.insert (Route.toString route) fromPage model.bfcache
            , defer = Defer.init [ Ports.setScroll (getScroll toPage) ]
            } => Cmd.none
      else
        model => Cmd.none

    Transitioning page route history toRoute ->
      if newRoute == route then
        -- user likely hit back. "finish" loading
        { model | pageState = Loaded page route history page route, progress = Progress.done model.progress } => Cmd.none
      else if newRoute /= toRoute then
        -- unlikely to happen. but meh
        case cachedPage of
          Nothing ->
            { model | pageState = Transitioning page route history newRoute, progress = Progress.start } => loadRoute newRoute

          Just toPage ->
            { model | pageState = Loaded page route history toPage newRoute, progress = Progress.done model.progress } => Cmd.none
      else
        model => Cmd.none

    Loaded page route history _ toRoute ->
      if newRoute == route then
        -- user likely hit back. "finish" loading
        { model | pageState = Loaded page route history page route } => Cmd.none
      else if newRoute /= toRoute then
        case cachedPage of
          Nothing ->
            { model | pageState = Transitioning page route history newRoute, progress = Progress.start } => loadRoute newRoute

          Just toPage ->
            { model | pageState = Loaded page route history toPage newRoute } => Cmd.none
      else
         model => Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Progress.subscriptions progressConfig model.progress
    , Ports.scroll Scroll
    , Defer.subscriptions model.defer |> Sub.map DeferMsg
    ]


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> UriUpdate)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
