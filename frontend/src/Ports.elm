port module Ports exposing (title, scroll, setScroll)

port title : String -> Cmd a

port scroll : (Int -> msg) -> Sub msg

port setScroll : Int -> Cmd a
