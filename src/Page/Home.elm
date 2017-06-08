module Page.Home exposing (view, update, Model, Msg(..), init)

{-| The homepage.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Data.Drink exposing (Drink)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Index
import Route exposing (Route)
import Task exposing (Task)


(=>) =
  (,)


-- MODEL --


type alias Model =
    { index : List Drink
    }

init : Task PageLoadError Model
init =
  let
    loadIndex =
      Request.Index.index
        |> Http.toTask

    handleLoadError _ =
      pageLoadError "Homepage is currently unavailable."
  in
  Task.map Model loadIndex
    |> Task.mapError handleLoadError

-- VIEW --


view : Model -> Html Msg
view model =
    div [ class "home-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ]
                    [ ul []
                        (List.map (\v -> li [] [ a [ Route.href (Route.Drink v.name), onPreventDefaultClick (UpdateUrl (Route.Drink v.name)) ] [ text v.name ] ]) model.index)
                    ]
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar" ]
                        [ p [] [ text "Popular Tags" ]
                        ]
                    ]
                ]
            ]
        ]

-- UPDATE --


type Msg
    = NoOp
    | UpdateUrl Route


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      model => Cmd.none

    _ ->
      model => Cmd.none
