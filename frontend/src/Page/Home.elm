module Page.Home exposing (view, update, Model, Msg(..), init)

{-| The homepage.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Data.Drink as Drink exposing (Drink)
import Data.Image as Image
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
  div [ class "content" ]
    [ div [ class "content-inner" ]
        [ div [ class "content-title" ]
            [ h3 [] [ text "All Drinks" ] ]
        , ul [ class "drinks-list" ]
            (List.map viewDrink model.index)
        ]
    ]


viewDrink : Drink -> Html Msg
viewDrink drink =
  li [ class "drink" ]
    [ div [ class "drink-img" ]
        [ a [ class "recipe-link", Route.href (Route.Drink drink.name), onPreventDefaultClick (UpdateUrl (Route.Drink drink.name)) ]
            [ case List.head drink.img of
                Nothing ->
                  img [ src (Image.missing drink.drinkware) ]
                    []
                Just img_ ->
                  img [ src ("/img/250x250/" ++ img_) ]
                    []
            ]
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
