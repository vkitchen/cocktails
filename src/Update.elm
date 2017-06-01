module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewPage (Ok newUrl) ->
      (Model model.page newUrl, Cmd.none)

    NewPage (Err _) ->
      (model, Cmd.none)
