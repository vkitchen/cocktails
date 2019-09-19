module Route exposing (Route(..), toString, href, modifyUrl, newUrl, fromLocation)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Http exposing (decodeUri, encodeUri)
import Navigation exposing (Location)
import Request.Helpers as Req exposing (prefixUrl)
import UrlParser as Url exposing (parsePath, s, (</>), custom, oneOf, Parser)

type Route
    = None
    | Home
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

prefix : Parser a b -> Parser a b
prefix p =
  s Req.prefix </> p

route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (prefix Url.top)
        , Url.map Home (prefix (s "index.html"))
        , Url.map Drink (prefix (s "drinks" </> decodedString))
        , Url.map Search (prefix (s "search" </> decodedString))
        ]


-- PUBLIC HELPERS --

toString : Route -> String
toString page =
  let
    pieces =
      case page of
        None ->
          [ "NONE" ]

        Home ->
          []

        Drink slug ->
          [ "drinks", slug ]

        Search slug ->
          [ "search", slug ]

  in
  "/" ++ (String.join "/" (List.map encodeUri pieces))


href : Route -> Attribute msg
href route =
  Attr.href (prefixUrl (toString route))


modifyUrl : Route -> Cmd msg
modifyUrl =
  toString >> prefixUrl >> Navigation.modifyUrl


newUrl : Route -> Cmd msg
newUrl =
  toString >> prefixUrl >> Navigation.newUrl


fromLocation : Location -> Route
fromLocation location =
  case parsePath route location of
    Nothing ->
      None

    Just route ->
      route
