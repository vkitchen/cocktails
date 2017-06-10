module Views.Page exposing (frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (..)
import Html.Attributes exposing (class, href, type_, src)
import Route exposing (Route)

{-| Take a page's Html and frame it with a header and footer.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
frame : Bool -> Html msg -> Html msg
frame isLoading content =
    div [ class "page-frame" ]
        [ viewHeader isLoading
        , content
        ]



viewHeader : Bool -> Html msg
viewHeader isLoading =
  nav [ class "masthead-container" ]
    [ div [ class "logo-container" ]
        [ a [ class "logo", Route.href Route.Home, class "logo" ] [ text "Tophat" ] ]
    -- , div [ class "masthead-user" ]
    --     [ span [ class "material-icons" ] [ text "notifications" ]
    --     , img [ src "/user/avatar.jpg" ] []
    --     , span [ class "material-icons" ] [ text "arrow_drop_down" ]
    --     ]
    , viewSearchBar
    ]

viewSearchBar : Html msg
viewSearchBar =
  div []
    [ form [ class "masthead-search" ]
        [ button [ class "search-btn" ] [ span [ class "material-icons search-btn-icon" ] [ text "search" ] ]
        , div [ class "masthead-search-terms" ]
            [ input [ class "masthead-search-term", type_ "text" ] [] ]
        ]
    ]
