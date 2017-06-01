module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (href)
import Model exposing (Model)
import Msg exposing (Msg)

(=>) =
  (,)

view : Model -> Html Msg
view model =
  ul []
    (List.map (\v -> li [] [ a [ href ("/" ++ v.file) ] [ text v.name ] ]) model.drinks)
