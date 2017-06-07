module Request.Helpers exposing (apiUrl)


apiUrl : String -> String
apiUrl str =
    str ++ ".json"
