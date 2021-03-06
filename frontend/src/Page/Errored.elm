module Page.Errored exposing (view, pageLoadError, PageLoadError)

{-| The page that renders when there was an error trying to load another page,
for example a Page Not Found error.

It includes a photo I took of a painting on a building in San Francisco,
of a giant walrus exploding the golden gate bridge with laser beams. Pew pew!

-}

import Html exposing (Html, main_, h1, div, img, text, p)
import Html.Attributes exposing (class, tabindex, id, alt)


-- MODEL --


type PageLoadError
    = PageLoadError Model


type alias Model =
    { errorMessage : String
    }


pageLoadError : String -> PageLoadError
pageLoadError errorMessage =
    PageLoadError { errorMessage = errorMessage }



-- VIEW --


view : PageLoadError -> Html msg
view (PageLoadError model) =
    main_ [ id "content", class "container", tabindex -1 ]
        [ h1 [] [ text "Error Loading Page" ]
        , div [ class "row" ]
            [ p [] [ text model.errorMessage ] ]
        ]
