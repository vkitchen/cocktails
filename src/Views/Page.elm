module Views.Page exposing (frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
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
        , viewFooter
        ]



viewHeader : Bool -> Html msg
viewHeader isLoading =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ text "Tophat" ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ]
            [ a [ class "logo-font", href "/" ] [ text "Tophat" ]
            , span [ class "attribution" ]
                [ text "© 2017"
                ]
            ]
        ]
