module Views.Page exposing (frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import ClickHandler exposing (onPreventDefaultClick)
import Html exposing (..)
import Html.Attributes exposing (class, href, type_, src, value)
import Html.Events exposing (onInput)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Route exposing (Route)

{-| Take a page's Html and frame it with a header and footer.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
frame : Bool -> Model -> Html Msg -> Html Msg
frame isLoading model content =
    div [ class "page-frame" ]
        [ viewHeader isLoading model
        , content
        ]


viewHeader : Bool -> Model -> Html Msg
viewHeader isLoading model =
  nav [ class "masthead-container" ]
    [ div [ class "logo-container" ]
        [ a [ class "logo", Route.href Route.Home, onPreventDefaultClick (UpdateUrl Route.Home) ] [ text "Tophat" ] ]
    -- , div [ class "masthead-user" ]
    --     [ span [ class "material-icons" ] [ text "notifications" ]
    --     , img [ src "/user/avatar.jpg" ] []
    --     , span [ class "material-icons" ] [ text "arrow_drop_down" ]
    --     ]
    , viewSearchBar model
    ]


viewSearchBar : Model -> Html Msg
viewSearchBar model =
  div []
    [ form [ class "masthead-search" ]
        [ button [ class "search-btn", onPreventDefaultClick (UpdateUrl (Route.Search model.query)) ]
            [ span [ class "material-icons search-btn-icon" ] [ text "search" ] ]
        , div [ class "masthead-search-terms" ]
            [ input [ class "masthead-search-term", type_ "text", value model.query, onInput UpdateQuery ] [] ]
        ]
    ]
