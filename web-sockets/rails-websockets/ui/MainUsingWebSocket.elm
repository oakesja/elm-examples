module MainUsingWebSocket exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)
import WebSocket
import Json.Encode
import Json.Decode exposing (andThen, (:=))


type Msg
    = ReceivedMessage String
    | SendMsg
    | Input String
    | ConnectTo
    | DisconnectFrom


init : ( Model, Cmd Msg )
init =
    Model.init ! []


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
                decodeMsg msgType =
                    case msgType of
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
                                Json.Decode.object3 Event
                                    ("userId" := Json.Decode.string)
                                    ("msg" := Json.Decode.string)
                                    ("action" := Json.Decode.string)
                        , Json.Decode.fail <| "Failed to decode: " ++ message
                        ]

                decodedMsg =
                    Result.withDefault Unknown <|
                        Json.Decode.decodeString decoder message
            in
                case decodedMsg of
                    ConnectedToChannel channel ->
                        case channel of
                            "AllMessagesChannel" ->
                                { model | status = Connected } ! []

                            _ ->
                                model ! []

                    Recieved channel event ->
                        case channel of
                            "AllMessagesChannel" ->
                                { model | events = model.events ++ [ event ] } ! []

                            _ ->
                                model ! []

                    _ ->
                        model ! []

        SendMsg ->
            model ! [ sendMessageToChannel "AllMessagesChannel" model.msgToSend ]

        Input msg ->
            { model | msgToSend = msg } ! []

        ConnectTo ->
            model ! [ connectToChannel "AllMessagesChannel" ]

        DisconnectFrom ->
            { model | status = Disconnected, events = [] }
                ! [ disconnectFromChannel "AllMessagesChannel" ]


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


disconnectFromChannel : String -> Cmd Msg
disconnectFromChannel name =
    WebSocket.send socketUrl <|
        Json.Encode.encode 0 <|
            Json.Encode.object
                [ ( "command", Json.Encode.string "unsubscribe" )
                , ( "identifier"
                  , Json.Encode.string <| "{\"channel\":\"" ++ name ++ "\"}"
                  )
                ]


sendMessageToChannel : String -> String -> Cmd Msg
sendMessageToChannel name msg =
    WebSocket.send socketUrl <|
        Json.Encode.encode 0 <|
            Json.Encode.object
                [ ( "command", Json.Encode.string "message" )
                , ( "identifier"
                  , Json.Encode.string <| "{\"channel\":\"" ++ name ++ "\"}"
                  )
                , ( "data"
                  , Json.Encode.string <|
                        Debug.log "data" <|
                            Json.Encode.encode 0 <|
                                Json.Encode.object
                                    [ ( "action", Json.Encode.string "sendMessage" )
                                    , ( "msg", Json.Encode.string msg )
                                    ]
                  )
                ]


socketUrl : String
socketUrl =
    "ws://localhost:3000/cable"


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
                { sendMsg = SendMsg
                , onInput = Input
                , disconnect = DisconnectFrom
                , connect = ConnectTo
                }
        }
