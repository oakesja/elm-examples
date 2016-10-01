module Model exposing (..)


type Status
    = Connected
    | Disconnected


type alias Message =
    { userId : String
    , msg : String
    }


type alias Model =
    { allStatus : Status
    , personalStatus : Status
    , allMsgs : List Message
    , personalMsgs : List Message
    }
