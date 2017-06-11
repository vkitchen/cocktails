module Data.Image exposing (missing)


-- PUBLIC HELPERS --

missing : String -> String
missing img =
  case img of
    "Cocktail glass" ->
      "/img/Cocktail Glass.svg"

    "Highball glass" ->
      "/img/Highball Glass.svg"

    "Hurricane glass" ->
      "/img/Hurrican Glass.svg"

    "Old Fashioned glass" ->
      "/img/Old Fashioned Glass.svg"

    "Shot glass" ->
      "/img/Shot Glass.svg"

    _ ->
      "/img/250x250/Missing.jpg"
