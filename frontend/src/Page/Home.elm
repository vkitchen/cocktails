module Page.Home exposing (Config, config, view, update, Model, Msg(..), init)

{-| The homepage.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Data.Drink as Drink exposing (Drink)
import Data.Image as Image
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (encodeUri)
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Index
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


view : Config msg -> Model -> Html msg
view config model =
  div [ class "content" ]
    [ div [ class "content-inner" ]
        [ div [ class "content-title" ]
            [ h3 [] [ text "All Drinks" ] ]
        , ul [ class "drinks-list" ]
            (List.map (viewDrink config) model.index)
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
