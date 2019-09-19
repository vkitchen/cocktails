module Request.Helpers exposing (prefix, prefixUrl, apiUrl)

prefix : String
prefix =
    "cocktails"

prefixUrl : String -> String
prefixUrl str =
    "/" ++ prefix ++ str

apiUrl : String -> String
apiUrl str =
    prefixUrl "/api/v1" ++ str
