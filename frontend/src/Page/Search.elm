module Page.Search exposing (view, update, Model, Msg(..), init, title)

{-| Display search results.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Data.Drink as Drink exposing (Drink)
import Data.Image as Image
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Search
import Route exposing (Route)
import Task exposing (Task)


(=>) =
  (,)


-- MODEL --


type alias Model =
    { query : String
    , results : List Drink
    }


init : String -> Task PageLoadError Model
init slug =
  let
    loadResults =
      Request.Search.search slug
        |> Http.toTask

    handleLoadError _ =
      pageLoadError "Search failed."
  in
  Task.map (Model slug) loadResults
    |> Task.mapError handleLoadError


title : Model -> String
title model =
  model.query



-- VIEW --


view : Model -> Html Msg
view model =
  div [ class "content" ]
    [ div [ class "content-inner" ]
        [ div [ class "content-title" ]
            [ h3 [] [ text "Search Results" ] ]
        , ul [ class "drinks-list" ]
            (List.map viewDrink model.results)
        ]
    ]


viewDrink : Drink -> Html Msg
viewDrink drink =
  li [ class "drink" ]
    [ div [ class "drink-img" ]
        [ case List.head drink.img of
            Nothing ->
              img [ src (Image.missing drink.drinkware) ]
                []
            Just img_ ->
              img [ src ("/img/" ++ img_) ]
                []
        ]
    , div [ class "recipe" ]
        [ h3 []
            [ a [ class "recipe-link", Route.href (Route.Drink drink.name), onPreventDefaultClick (UpdateUrl (Route.Drink drink.name)) ]
                [ text drink.name ]
            ]
        , ul [ class "ingredient-list" ]
            (List.map (\v -> li [] [ text (Drink.renderIngredient v) ]) drink.ingredients)
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
