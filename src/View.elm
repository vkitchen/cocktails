module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, href, src, class, type_)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (..)

(=>) =
  (,)

view : Model -> Html Msg
view model =
  if model.url == "" then
    index model
  else
    drink model

drink : Model -> Html Msg
drink model =
  case model.drink of
    Nothing -> div [] [ h1 [] [ text model.url ] ]
    Just d ->
      div []
        [ header
        , h1 [] [ text model.url ]
        , p [] [ text ("Drinkware: " ++ d.drinkware) ]
        , p [] [ text ("Serve: " ++ d.serve) ]
        , p [] [ text ("Garnish: " ++ if d.garnish == [] then "None" else String.join ", " d.garnish) ]
        , ul []
            (List.map (\v -> li [] [ ingredient v ]) d.ingredients)
        , p [] [ text d.method ]
        ]

ingredient : DrinkIngredient -> Html Msg
ingredient v =
  text (v.measure ++ " " ++ v.unit ++ " " ++ v.name)

index : Model -> Html Msg
index model =
  div []
    [ header
    , ul []
        (List.map (\v -> li [] [ a [ href ("#" ++ v.name) ] [ text v.name ] ]) model.index)
    ]

header : Html Msg
header =
  div [ headerStyle ]
    [ div [ logoContainerStyle ]
        [ a [ logoStyle, href "/", class "logo" ] [ text "Tophat" ] ]
    , div [ userContainerStyle ]
        -- [ span [ class "material-icons" ] [ text "notifications" ]
        [ img [ avatarStyle, src "/user/avatar.jpg" ] []
        -- , span [ class "material-icons" ] [ text "arrow_drop_down" ]
        ]
    , searchBar
    ]

searchBar : Html Msg
searchBar =
  div []
    [ form [ searchStyle ]
        [ button [ searchButtonStyle ] [ span [ magnifyStyle, class "material-icons" ] [ text "search" ] ]
        , div [ searchInputContainerStyle ]
            [ input [ searchInputStyle, type_ "text", onInput Msg.FilterDrinks ] [] ]
        ]
    ]


-- styles

headerStyle : Attribute Msg
headerStyle =
  style
    [ "border-bottom" => "2px solid #000"
    , "min-width" => "0"
    , "padding-bottom" => "8px"
    , "padding-top" => "7px"
    , "position" => "relative"
    , "padding-left" => "30px"
    , "padding-right" => "30px"
    , "margin" => "0 5px"
    ]

logoContainerStyle : Attribute Msg
logoContainerStyle =
  style
    [ "float" => "left"
    , "margin-top" => "3px"
    , "position" => "relative"
    , "width" => "200px"
    ]

logoStyle : Attribute Msg
logoStyle =
  style
    [ "font-family" => "Open Sans, sans-serif"
    , "font-size" => "42px"
    , "font-weight" => "bold"
    , "line-height" => "40px"
    ]


searchStyle : Attribute Msg
searchStyle =
  style
    [ "max-width" => "650px"
    , "overflow" => "hidden"
    , "padding" => "0"
    , "margin" => "0"
    , "border" => "0"
    , "position" => "relative"
    ]

searchInputContainerStyle : Attribute Msg
searchInputContainerStyle =
  style
    [ "height" => "44px"
    , "line-height" => "30px"
    , "margin" => "0 0 2px"
    , "overflow" => "hidden"
    , "position" => "relative"
    , "box-sizing" => "border-box"
    , "border" => "1px solid #ccc"
    ]

searchInputStyle : Attribute Msg
searchInputStyle =
  style
    [ "color" => "#767676"
    , "display" => "inline-block"
    , "border" => "0"
    , "height" => "100%"
    , "left" => "0"
    , "margin" => "0"
    , "padding" => "2px 6px"
    , "position" => "absolute"
    , "width" => "100%"
    , "box-sizing" => "border-box"
    , "font-size" => "14px"
    ]

searchButtonStyle : Attribute Msg
searchButtonStyle =
  style
    [ "border" => "0"
    , "padding" => "0"
    , "float" => "right"
    , "height" => "44px"
    , "background" => "#f8f8f8"
    , "color" => "#333"
    , "display" => "inline-block"
    , "border" => "solid 1px #d3d3d3"
    , "border-left" => "0"
    , "vertical-align" => "middle"
    , "white-space" => "nowrap"
    ]

magnifyStyle : Attribute Msg
magnifyStyle =
  style
    [ "display" => "block"
    , "height" => "24px"
    , "margin" => "0 25px"
    ]

userContainerStyle : Attribute Msg
userContainerStyle =
  style
    [ "color" => "#555"
    , "float" => "right"
    , "margin-left" => "50px"
    , "margin-top" => "3px"
    ]

avatarStyle : Attribute Msg
avatarStyle =
  style
    [ "border-radius" => "2px"
    ]
