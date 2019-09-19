module Views.Frame exposing (State, Config, config, init, updateSearch, frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Html exposing (..)
import Html.Attributes exposing (class, href, type_, src, value)
import Html.Events exposing (onInput)
import Route exposing (Route)


type State =
  State String


type Config msg =
  Config
    { changePage : Route -> msg
    , updateState : State -> msg
    }


config : { changePage : Route -> msg, updateState : State -> msg } -> Config msg
config { changePage, updateState } =
  Config
    { changePage = changePage
    , updateState = updateState
    }


init : State
init =
  State ""


updateSearch : Route -> State -> State
updateSearch route state =
  case route of
    Route.Search slug ->
      State slug

    _ ->
      state


{-| Take a page's Html and frame it with a header and footer.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
frame : Html msg -> Config msg -> State -> Html msg -> Html msg
frame progressBar config query content =
    div [ class "page-frame" ]
        [ progressBar
        , viewHeader config query
        , content
        ]


viewHeader : Config msg -> State -> Html msg
viewHeader (Config { changePage, updateState } as config) query =
  nav [ class "masthead-container" ]
    [ div [ class "logo-container" ]
        [ a [ class "logo", href "/" ] [ text "VK" ] ]
    , viewSearchBar config query
    ]


viewSearchBar : Config msg -> State -> Html msg
viewSearchBar (Config { changePage, updateState }) (State query) =
  div []
    [ form [ class "masthead-search" ]
        [ button [ class "search-btn", onPreventDefaultClick (changePage (Route.Search query)) ]
            [ span [ class "material-icons search-btn-icon" ] [ text "search" ] ]
        , div [ class "masthead-search-terms" ]
            [ input [ class "masthead-search-term", type_ "text", value query, onInput (updateState << State) ] [] ]
        ]
    ]
