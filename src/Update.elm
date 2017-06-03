module Update exposing (update)

import Http
import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChange location ->
      let
        newUrl = Maybe.withDefault "" (Http.decodeUri (String.dropLeft 1 location.hash))
      in
      ({model | url = newUrl }, Model.getPage ("/" ++ getDrinkPath newUrl model.index))

    UpdateIndex (Ok drinksList) ->
      ({ model | index = drinksList }, Cmd.none)

    UpdateIndex (Err _) ->
      (model, Cmd.none)

    UpdatePage (Ok drink) ->
      ({ model | drink = Just drink }, Cmd.none)

    UpdatePage (Err _) ->
      (model, Cmd.none)

    FilterDrinks query ->
      ({ model | query = query }, Model.getSearch query)

getDrinkPath : String -> List DrinkPath -> String
getDrinkPath name l =
  (Maybe.withDefault (DrinkPath "" "") (List.head (List.filter (\v -> v.name == name) l))).file
