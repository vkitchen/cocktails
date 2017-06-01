module Types exposing (..)

type alias DrinkPath =
  { file : String
  , name : String
  }

type alias DrinkIngredient =
  { name : String
  , measure : String
  , unit : String
  }

type alias Drink =
  { name : String
  , iba : Bool
  , class : String
  , serve : String
  , garnish : List String
  , drinkware : String
  , ingredients : List DrinkIngredient
  , method : String
  }
