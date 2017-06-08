module Page.Drink exposing (view, update, Model, Msg, init)

{-| The homepage.
-}

import Data.Drink exposing (Drink, DrinkIngredient)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
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



-- VIEW --


view : Model -> Html Msg
view model =
    div [ class "home-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ]
                    [ h1 [] [ text model.drink.name ]
                    , p [] [ text ("Drinkware: " ++ model.drink.drinkware) ]
                    , p [] [ text ("Serve: " ++ model.drink.serve) ]
                    , p [] [ text ("Garnish: " ++ if model.drink.garnish == "" then "None" else model.drink.garnish) ]
                    , ul []
                        (List.map (\v -> li [] [ viewIngredient v ]) model.drink.ingredients)
                    , p [] [ text model.drink.method ]
                    ]
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar" ]
                        [ p [] [ text "Popular Tags" ]
                        ]
                    ]
                ]
            ]
        ]


viewIngredient : DrinkIngredient -> Html Msg
viewIngredient v =
  text (v.measure ++ " " ++ v.unit ++ " " ++ v.name)


-- UPDATE --


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      model => Cmd.none
