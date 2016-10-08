module Model exposing (..)


type Status
    = Connected
    | Disconnected


type alias Event =
    { userId : String
    , msg : String
    , action : String
    }


type alias Model =
    { status : Status
    , events : List Event
    }


init : Model
init =
    { status = Disconnected
    , events = []
    }
