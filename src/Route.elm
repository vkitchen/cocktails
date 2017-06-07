module Route exposing (Route(..), href, fromLocation)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing (parseHash, s, (</>), string, oneOf, Parser)

type Route
    = Home
    | Drink String

route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home Url.top
        , Url.map Drink (s "drinks" </> string)
        ]

routeToString : Route -> String
routeToString page =
  let
    pieces =
      case page of
        Home ->
          []

        Drink slug ->
          [ "article", slug ]

  in
  "/" ++ (String.join "/" pieces)

-- PUBLIC HELPERS --

href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)

fromLocation : Location -> Maybe Route
fromLocation location =
    parseHash route location
