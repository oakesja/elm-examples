port module MainWithPorts exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)


type Msg
    = ConnectedTo String
    | DisconnectedFrom String
    | AddMsg StreamEvent
    | SendMsgToAll
    | SendMsgToSelf


init : ( Model, Cmd Msg )
init =
    { allStatus = Disconnected
    , personalStatus = Disconnected
    , allEvents = []
    , personalEvents = []
    }
        ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnectedTo streamName ->
            case streamName of
                "all" ->
                    { model | allStatus = Connected } ! []

                _ ->
                    { model | personalStatus = Connected } ! []

        DisconnectedFrom streamName ->
            case streamName of
                "all" ->
                    { model | allStatus = Disconnected } ! []

                _ ->
                    { model | personalStatus = Disconnected } ! []

        AddMsg { streamName, event } ->
            case streamName of
                "all" ->
                    { model | allEvents = model.allEvents ++ [ event ] } ! []

                _ ->
                    { model | personalEvents = model.personalEvents ++ [ event ] } ! []

        SendMsgToAll ->
            model ! [ sendEventToAll () ]

        SendMsgToSelf ->
            model ! [ sendEventToSelf () ]


type alias StreamEvent =
    { streamName : String
    , event : Event
    }


port connected : (String -> msg) -> Sub msg


port disconnected : (String -> msg) -> Sub msg


port receiveEvent : (StreamEvent -> msg) -> Sub msg


port sendEventToAll : () -> Cmd msg


port sendEventToSelf : () -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ connected ConnectedTo
        , disconnected DisconnectedFrom
        , receiveEvent AddMsg
        ]


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view =
            view
                { sendMsgToAll = SendMsgToAll
                , sendMsgToSelf = SendMsgToSelf
                }
        }
