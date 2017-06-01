import Html exposing (program)
import Model exposing (Model)
import Msg exposing (..)
import Navigation
import Update
import View


main =
  Navigation.program UrlChange
    { init = Model.init
    , view = View.view
    , update = Update.update
    , subscriptions = subscriptions
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
