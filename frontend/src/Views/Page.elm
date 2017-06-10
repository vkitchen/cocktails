module Views.Page exposing (frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Html exposing (..)
import Html.Attributes exposing (class, href, type_, src)
import Msg exposing (Msg(..))
import Route exposing (Route)

{-| Take a page's Html and frame it with a header and footer.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
frame : Bool -> Html Msg -> Html Msg
frame isLoading content =
    div [ class "page-frame" ]
        [ viewHeader isLoading
        , content
        ]



viewHeader : Bool -> Html Msg
viewHeader isLoading =
  nav [ class "masthead-container" ]
    [ div [ class "logo-container" ]
        [ a [ class "logo", Route.href Route.Home, onPreventDefaultClick (UpdateUrl Route.Home) ] [ text "Tophat" ] ]
    -- , div [ class "masthead-user" ]
    --     [ span [ class "material-icons" ] [ text "notifications" ]
    --     , img [ src "/user/avatar.jpg" ] []
    --     , span [ class "material-icons" ] [ text "arrow_drop_down" ]
    --     ]
    , viewSearchBar
    ]

viewSearchBar : Html Msg
viewSearchBar =
  div []
    [ form [ class "masthead-search" ]
        [ button [ class "search-btn" ] [ span [ class "material-icons search-btn-icon" ] [ text "search" ] ]
        , div [ class "masthead-search-terms" ]
            [ input [ class "masthead-search-term", type_ "text" ] [] ]
        ]
    ]
