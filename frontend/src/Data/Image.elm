module Data.Image exposing (missing)

import Request.Helpers exposing (prefixUrl)

-- PUBLIC HELPERS --

missing : String -> String
missing img =
  prefixUrl
    <|
      case img of
        "Cocktail glass" ->
          "/img/Cocktail Glass.svg"
    
        "Champagne flute" ->
          "/img/Champagne Flute.svg"
    
        "Highball glass" ->
          "/img/Highball Glass.svg"
    
        "Hurricane glass" ->
          "/img/Hurricane Glass.svg"
    
        "Old Fashioned glass" ->
          "/img/Old Fashioned Glass.svg"
    
        "Shot glass" ->
          "/img/Shot Glass.svg"
    
        _ ->
          "/img/250x250/Missing.jpg"
