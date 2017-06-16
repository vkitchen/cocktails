module Views.Page exposing (Config, config, frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Html exposing (..)
import Html.Attributes exposing (class, href, type_, src, value)
import Html.Events exposing (onInput)
import Route exposing (Route)


type Config msg =
  Config
    { pageChange : Route -> msg
    , stateChange : String -> msg
    }


config : { pageChange : Route -> msg, stateChange : String -> msg } -> Config msg
config { pageChange, stateChange } =
  Config
    { pageChange = pageChange
    , stateChange = stateChange
    }


{-| Take a page's Html and frame it with a header and footer.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
frame : Config msg -> String -> Html msg -> Html msg
frame config query content =
    div [ class "page-frame" ]
        [ viewHeader config query
        , content
        ]


viewHeader : Config msg -> String -> Html msg
viewHeader (Config { pageChange, stateChange } as config) query =
  nav [ class "masthead-container" ]
    [ div [ class "logo-container" ]
        [ a [ class "logo", Route.href Route.Home, onPreventDefaultClick (pageChange Route.Home) ] [ text "Tophat" ] ]
    -- , div [ class "masthead-user" ]
    --     [ span [ class "material-icons" ] [ text "notifications" ]
    --     , img [ src "/user/avatar.jpg" ] []
    --     , span [ class "material-icons" ] [ text "arrow_drop_down" ]
    --     ]
    , viewSearchBar config query
    ]


viewSearchBar : Config msg -> String -> Html msg
viewSearchBar (Config { pageChange, stateChange }) query =
  div []
    [ form [ class "masthead-search" ]
        [ button [ class "search-btn", onPreventDefaultClick (pageChange (Route.Search query)) ]
            [ span [ class "material-icons search-btn-icon" ] [ text "search" ] ]
        , div [ class "masthead-search-terms" ]
            [ input [ class "masthead-search-term", type_ "text", value query, onInput stateChange ] [] ]
        ]
    ]
