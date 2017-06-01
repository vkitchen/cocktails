module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateIndex (Ok drinksList) ->
      ({ model | index = drinksList }, Cmd.none)

    UpdateIndex (Err _) ->
      (model, Cmd.none)

    UpdatePage (Ok drink) ->
      ({ model | drink = Just drink }, Cmd.none)

    UpdatePage (Err _) ->
      (model, Cmd.none)

    ChangePage newUrl ->
      ({ model | url = newUrl }, Model.getPage ("/" ++ getDrinkPath newUrl model.index))

getDrinkPath : String -> List DrinkPath -> String
getDrinkPath name l =
  (Maybe.withDefault (DrinkPath "" "") (List.head (List.filter (\v -> v.name == name) l))).file
