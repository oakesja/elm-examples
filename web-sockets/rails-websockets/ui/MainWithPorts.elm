port module MainWithPorts exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)


type Msg
    = ConnectedTo String
    | DisconnectedFrom String
    | AddMsg StreamMsg
    | SendMsgToAll
    | SendMsgToSelf


init : ( Model, Cmd Msg )
init =
    { allStatus = Disconnected
    , personalStatus = Disconnected
    , allMsgs = []
    , personalMsgs = []
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
                    { model | personalStatus = Disconnected } ! []

                _ ->
                    { model | personalStatus = Connected } ! []

        AddMsg { streamName, msg } ->
            case streamName of
                "all" ->
                    { model | allMsgs = model.allMsgs ++ [ msg ] } ! []

                _ ->
                    { model | personalMsgs = model.personalMsgs ++ [ msg ] } ! []

        SendMsgToAll ->
            model ! [ sendMessageToAll () ]

        SendMsgToSelf ->
            model ! [ sendMessageToSelf () ]


type alias StreamMsg =
    { streamName : String
    , msg : Message
    }


port connected : (String -> msg) -> Sub msg


port disconnected : (String -> msg) -> Sub msg


port addMsg : (StreamMsg -> msg) -> Sub msg


port sendMessageToAll : () -> Cmd msg


port sendMessageToSelf : () -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ connected ConnectedTo
        , disconnected DisconnectedFrom
        , addMsg AddMsg
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
