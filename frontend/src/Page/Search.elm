module Page.Search exposing (Config, config, view, update, Model, Msg(..), init, title)

{-| Display search results.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Data.Drink as Drink exposing (Drink)
import Data.Image as Image
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (encodeUri)
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Search
import Route exposing (Route)
import Task exposing (Task)


(=>) =
  (,)


type Config msg =
  Config
    { changePage : Route -> msg
    , toMsg : Msg -> msg
    }


config : { changePage : Route -> msg, toMsg : Msg -> msg } -> Config msg
config { changePage, toMsg } =
  Config
    { changePage = changePage
    , toMsg = toMsg
    }


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


searchBy : String -> Drink -> Bool
searchBy query drink =
  String.contains (String.toLower query) (String.toLower drink.name)
  || (drink.ingredients
       |> List.map (String.toLower << .name)
       |> List.any (String.contains (String.toLower query))
     )


-- VIEW --


view : Config msg -> Model -> Html msg
view config model =
  let
    filtered = List.filter (searchBy model.query) model.results
  in
    div [ class "content" ]
      [ div [ class "content-inner" ]
          [ div [ class "content-title" ]
              [ h3 [] [ text "Search Results" ] ]
          , ul [ class "drinks-list" ]
              (List.map (viewDrink config) filtered)
          ]
      ]


viewDrink : Config msg -> Drink -> Html msg
viewDrink (Config { changePage, toMsg }) drink =
  li [ class "drink" ]
    [ div [ class "drink-img" ]
        [ a [ class "recipe-link", Route.href (Route.Drink drink.name), onPreventDefaultClick (changePage (Route.Drink drink.name)) ]
            [ case List.head drink.img of
                Nothing ->
                  img [ src (Image.missing drink.drinkware) ]
                    []
                Just img_ ->
                  img [ src ("/img/250x250/" ++ (encodeUri img_)) ]
                    []
            ]
        ]
    , div [ class "recipe" ]
        [ h3 []
            [ a [ class "recipe-link", Route.href (Route.Drink drink.name), onPreventDefaultClick (changePage (Route.Drink drink.name)) ]
                [ text drink.name ]
            ]
        , ul [ class "ingredient-list" ]
            (List.map (\v -> li [] [ text (Drink.renderIngredient v) ]) drink.ingredients)
        ]
    ]


-- UPDATE --


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      model => Cmd.none
