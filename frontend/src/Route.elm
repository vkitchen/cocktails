module Route exposing (Route(..), href, modifyUrl, newUrl, fromLocation)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Http exposing (decodeUri)
import Navigation exposing (Location)
import UrlParser as Url exposing (parsePath, s, (</>), custom, oneOf, Parser)

type Route
    = Home
    | Drink String
    | Search String


decodedString =
  custom "STRING" <|
    \encoded ->
      case decodeUri encoded of
        Nothing ->
          Ok encoded

        Just decoded ->
          Ok decoded


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home Url.top
        , Url.map Drink (s "drinks" </> decodedString)
        , Url.map Search (s "search" </> decodedString)
        ]

routeToString : Route -> String
routeToString page =
  let
    pieces =
      case page of
        Home ->
          []

        Drink slug ->
          [ "drinks", slug ]

        Search slug ->
          [ "search", slug ]

  in
  "/" ++ (String.join "/" pieces)

-- PUBLIC HELPERS --

href : Route -> Attribute msg
href route =
  Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
  routeToString >> Navigation.modifyUrl


newUrl : Route -> Cmd msg
newUrl =
  routeToString >> Navigation.newUrl


fromLocation : Location -> Maybe Route
fromLocation location =
  parsePath route location
