port module MainWithSockets exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)
import WebSocket
import Json.Encode
import Json.Decode exposing (andThen, (:=))


type Msg
    = ReceivedMessage String
    | SendMsgToAll
    | SendMsgToSelf


init : ( Model, Cmd Msg )
init =
    { allStatus = Disconnected
    , personalStatus = Disconnected
    , allEvents = []
    , personalEvents = []
    }
        ! [ connectToChannel "AllMessagesChannel"
          , connectToChannel "PersonalMessagesChannel"
          ]


connectToChannel : String -> Cmd Msg
connectToChannel name =
    WebSocket.send socketUrl <|
        Json.Encode.encode 0 <|
            Json.Encode.object
                [ ( "command", Json.Encode.string "subscribe" )
                , ( "identifier"
                  , Json.Encode.string <| "{\"channel\":\"" ++ name ++ "\"}"
                  )
                ]


sendMessageToChannel : String -> Cmd Msg
sendMessageToChannel name =
    WebSocket.send socketUrl <|
        Json.Encode.encode 0 <|
            Json.Encode.object
                [ ( "command", Json.Encode.string "message" )
                , ( "identifier"
                  , Json.Encode.string <| "{\"channel\":\"" ++ name ++ "\"}"
                  )
                , ( "data"
                  , Json.Encode.string <|
                        Json.Encode.encode 0 <|
                            Json.Encode.object
                                [ ( "action", Json.Encode.string "sendMessage" ) ]
                  )
                ]


socketUrl : String
socketUrl =
    "ws://localhost:3000/cable"


type SocketMsg
    = Ping
    | ConnectedToChannel String
    | Recieved String Event
    | Unknown


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedMessage message ->
            let
                _ =
                    Debug.log "raw message" message

                decodeMsg msgType =
                    case Debug.log "msgType" msgType of
                        "ping" ->
                            Json.Decode.succeed Ping

                        "confirm_subscription" ->
                            Json.Decode.object1 ConnectedToChannel <|
                                Json.Decode.customDecoder ("identifier" := Json.Decode.string) <|
                                    Json.Decode.decodeString ("channel" := Json.Decode.string)

                        _ ->
                            Json.Decode.succeed Unknown

                decoder =
                    Json.Decode.oneOf
                        [ ("type" := Json.Decode.string) `andThen` decodeMsg
                        , Json.Decode.object2 Recieved
                            (Json.Decode.customDecoder
                                ("identifier" := Json.Decode.string)
                             <|
                                Json.Decode.decodeString ("channel" := Json.Decode.string)
                            )
                          <|
                            Json.Decode.at [ "message" ] <|
                                Json.Decode.object2 Event
                                    ("userId" := Json.Decode.string)
                                    ("msg" := Json.Decode.string)
                        , Json.Decode.fail <| "Failed to decode: " ++ message
                        ]

                decodedMsg =
                    Result.withDefault Unknown <|
                        Json.Decode.decodeString decoder message

                _ =
                    Debug.log "decoded message" decodedMsg
            in
                case decodedMsg of
                    ConnectedToChannel channel ->
                        case channel of
                            "AllMessagesChannel" ->
                                { model | allStatus = Connected } ! []

                            "PersonalMessagesChannel" ->
                                { model | personalStatus = Connected } ! []

                            _ ->
                                model ! []

                    Recieved channel event ->
                        case channel of
                            "AllMessagesChannel" ->
                                { model | allEvents = model.allEvents ++ [ event ] } ! []

                            "PersonalMessagesChannel" ->
                                { model | personalEvents = model.personalEvents ++ [ event ] } ! []

                            _ ->
                                model ! []

                    _ ->
                        model ! []

        SendMsgToAll ->
            model ! [ sendMessageToChannel "AllMessagesChannel" ]

        SendMsgToSelf ->
            model ! [ sendMessageToChannel "PersonalMessagesChannel" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen socketUrl ReceivedMessage


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
