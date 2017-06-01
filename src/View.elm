module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (..)

(=>) =
  (,)

view : Model -> Html Msg
view model =
  if model.url == "index" then
    index model
  else
    drink model

drink : Model -> Html Msg
drink model =
  case model.drink of
    Nothing -> div [] [ h1 [] [ text model.url ] ]
    Just d ->
      div []
        [ h1 [] [ text model.url ]
        , p [] [ text ("Drinkware: " ++ d.drinkware) ]
        , p [] [ text ("Serve: " ++ d.serve) ]
        , p [] [ text ("Garnish: " ++ if d.garnish == [] then "None" else String.join ", " d.garnish) ]
        , ul []
            (List.map (\v -> li [] [ ingredient v ]) d.ingredients)
        , p [] [ text d.method ]
        ]

ingredient : DrinkIngredient -> Html Msg
ingredient v =
  text (v.measure ++ " " ++ v.unit ++ " " ++ v.name)

index : Model -> Html Msg
index model =
  ul []
    (List.map (\v -> li [] [ a [ onClick (Msg.ChangePage v.name), href ("#" ++ v.name) ] [ text v.name ] ]) model.index)
