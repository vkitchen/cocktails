module Main exposing (main)

import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Msg exposing (Msg(..))
import Navigation exposing (Location)
import Page.Drink as Drink
import Page.Errored as Errored exposing (PageLoadError)
import Page.Home as Home
import Page.NotFound as NotFound
import Ports
import Route exposing (Route)
import Task
import Views.Page as Page


(=>) =
  (,)


type Page
  = Blank
  | NotFound
  | Errored PageLoadError
  | Home Home.Model
  | Drink Drink.Model


type PageState
  = Loaded Page
  | TransitioningFrom Page


type alias Model =
  { pageState : PageState
  }


init : Value -> Location -> ( Model, Cmd Msg )
init _ location =
  setRoute (Route.fromLocation location)
    { pageState = Loaded Blank
    }


getPage : PageState -> Page
getPage pageState =
  case pageState of
    Loaded page ->
      page

    TransitioningFrom page ->
      page



-- VIEW --


view : Model -> Html Msg
view model =
  case model.pageState of
    Loaded page ->
      viewPage False page

    TransitioningFrom page ->
      viewPage True page


viewPage : Bool -> Page -> Html Msg
viewPage isLoading page =
  let
    frame =
      Page.frame isLoading
  in
  case page of
    NotFound ->
      NotFound.view
        |> frame

    Blank ->
      Html.text ""
        |> frame

    Errored subModel ->
      Errored.view subModel
        |> frame

    Home subModel ->
      Home.view subModel
        |> Html.map HomeMsg
        |> frame

    Drink subModel ->
      Drink.view subModel
        |> Html.map DrinkMsg
        |> frame



-- UPDATE --

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
  let
    toPage toModel toMsg subUpdate subMsg subModel =
      let
        ( newModel, newCmd ) =
          subUpdate subMsg subModel
      in
      ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )
  in
  case ( msg, page ) of
    ( SetRoute route, _ ) ->
      setRoute route model

    ( UpdateUrl route, _ ) ->
      model => Route.newUrl route

    ( HomeLoaded (Ok subModel), _ ) ->
      { model | pageState = Loaded (Home subModel) } => Ports.title "All Drinks - Tophat"

    ( HomeLoaded (Err error), _ ) ->
      { model | pageState = Loaded (Errored error) } => Ports.title "All Drinks - Tophat"

    ( DrinkLoaded (Ok subModel), _ ) ->
      { model | pageState = Loaded (Drink subModel) } => Ports.title (Drink.title subModel ++ " - Tophat")

    ( DrinkLoaded (Err error), _ ) ->
      { model | pageState = Loaded (Errored error) } => Cmd.none

    ( HomeMsg (Home.UpdateUrl route), _ ) ->
      model => Route.newUrl route

    ( HomeMsg subMsg, Home subModel ) ->
      toPage Home HomeMsg Home.update subMsg subModel

    ( DrinkMsg subMsg, Drink subModel ) ->
      toPage Drink DrinkMsg Drink.update subMsg subModel

    ( _, _ ) ->
        -- Disregard incoming messages that arrived for the wrong page
        model => Cmd.none


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
  let
    transition toMsg task =
      { model | pageState = TransitioningFrom (getPage model.pageState) }
        => Task.attempt toMsg task

    errored =
      pageErrored model
  in
  case maybeRoute of
    Nothing ->
      { model | pageState = Loaded NotFound } => Cmd.none

    Just Route.Home ->
        transition HomeLoaded Home.init

    Just (Route.Drink slug) ->
        transition DrinkLoaded (Drink.init slug)


pageErrored : Model -> String -> ( Model, Cmd msg )
pageErrored model errorMessage =
  let
    error =
      Errored.pageLoadError errorMessage
  in
  { model | pageState = Loaded (Errored error) } => Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
