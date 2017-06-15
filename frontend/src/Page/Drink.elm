module Page.Drink exposing (view, update, Model, Msg, init, title)

{-| The homepage.
-}

import Data.Drink as Drink exposing (Drink, DrinkIngredient)
import Data.Image as Image
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (encodeUri)
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Request.Drink
import Task exposing (Task)


(=>) =
  (,)


-- MODEL --


type alias Model =
    { drink : Drink
    }


init : String -> Task PageLoadError Model
init slug =
  let
    loadDrink =
      Request.Drink.drink slug
        |> Http.toTask

    handleLoadError _ =
      pageLoadError "Drink is currently unavailable."
  in
  Task.map Model loadDrink
    |> Task.mapError handleLoadError


title : Model -> String
title model =
  model.drink.name



-- VIEW --


view : Model -> Html Msg
view model =
  div [ class "content" ]
    [ div [ class "content-inner" ]
        [ div [ class "content-title" ]
            [ h3 [] [ text model.drink.name ] ]
        , div [ class "drink" ]
            [ div [ class "drink-img" ]
                [ case List.head model.drink.img of
                    Nothing ->
                      img [ src (Image.missing model.drink.drinkware) ]
                        []
                    Just img_ ->
                      img [ src ("/img/250x250/" ++ (encodeUri img_)) ]
                        []
                ]
            , div [ class "recipe" ]
                [ p [] [ text ("Drinkware: " ++ model.drink.drinkware) ]
                , p [] [ text ("Serve: " ++ model.drink.serve) ]
                , p [] [ text ("Garnish: " ++ if model.drink.garnish == "" then "None" else model.drink.garnish) ]
                , ul []
                    (List.map (\v -> li [] [ text (Drink.renderIngredient v) ]) model.drink.ingredients)
                , p [] [ text model.drink.method ]
                ]
            ]
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
