module Model exposing (..)


type Status
    = Connected
    | Disconnected


type alias Event =
    { userId : String
    , msg : String
    }


type alias Model =
    { allStatus : Status
    , personalStatus : Status
    , allEvents : List Event
    , personalEvents : List Event
    }
