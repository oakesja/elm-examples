port module MainWithSockets exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)
import WebSocket
import Json.Encode as Json


type Msg
    = ReceivedMessage String
    | SendMsgToAll
    | SendMsgToSelf


init : ( Model, Cmd Msg )
init =
    { allStatus = Disconnected
    , personalStatus = Disconnected
    , allMsgs = []
    , personalMsgs = []
    }
        ! [ WebSocket.send "ws://localhost:3000/cable" <|
                Json.encode 0 <|
                    Json.object
                        [ ( "command", Json.string "subscribe" )
                        , ( "identifier"
                          , Json.string "{\"channel\":\"AllMessagesChannel\"}"
                          )
                        ]
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedMessage message ->
            let
                _ =
                    Debug.log "recieved message" message
            in
                model ! []

        SendMsgToAll ->
            model ! []

        SendMsgToSelf ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:3000/cable" ReceivedMessage


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
