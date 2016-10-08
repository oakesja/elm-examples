module RailsWebSocket exposing (..)

import WebSocket
import Json.Decode as Json exposing (Decoder, andThen, (:=))
import Json.Encode


-- TODO
-- validate channels given
-- validate unique names
-- too much wiring, socket url and channels needed all over the place
-- figure out how to handle disconnect


type alias Channel a msg =
    { name : String
    , onConnect : msg
    , onReject : msg
    , onMessage : a -> msg
    , messageDecoder : Decoder a
    }


listen : String -> msg -> List (Channel a msg) -> Sub msg
listen url noOp channels =
    WebSocket.listen url (channelListener noOp channels)



--  TODO need a disconnect


connect : String -> Channel a msg -> Cmd msg
connect url channel =
    WebSocket.send url <|
        Json.Encode.encode 0 <|
            Json.Encode.object
                [ ( "command", Json.Encode.string "subscribe" )
                , ( "identifier"
                  , Json.Encode.string <| "{\"channel\":\"" ++ channel.name ++ "\"}"
                  )
                ]



-- TODO need to handle data


perform : String -> String -> Channel a msg -> Cmd msg
perform url action channel =
    WebSocket.send url <|
        Json.Encode.encode 0 <|
            Json.Encode.object
                [ ( "command", Json.Encode.string "message" )
                , ( "identifier"
                  , Json.Encode.string <| "{\"channel\":\"" ++ channel.name ++ "\"}"
                  )
                , ( "data"
                  , Json.Encode.string <|
                        Json.Encode.encode 0 <|
                            Json.Encode.object
                                [ ( "action", Json.Encode.string action ) ]
                  )
                ]


channelListener : msg -> List (Channel a msg) -> String -> msg
channelListener noOp channels message =
    Json.decodeString (messageDecoder noOp channels) message
        |> Result.withDefault noOp


messageDecoder : msg -> List (Channel a msg) -> Decoder msg
messageDecoder noOp channels =
    Json.oneOf
        [ messageWithTypeDecoder noOp channels
        , actualMessageDecoder noOp channels
        ]


actualMessageDecoder : msg -> List (Channel a msg) -> Decoder msg
actualMessageDecoder noOp channels =
    channelNameDecoder
        `andThen`
            \channelName ->
                case findMatchingChannel channelName channels of
                    Just channel ->
                        Json.map channel.onMessage channel.messageDecoder
                            |> Json.at [ "message" ]

                    Nothing ->
                        Json.succeed noOp


messageWithTypeDecoder : msg -> List (Channel a msg) -> Decoder msg
messageWithTypeDecoder noOp channels =
    ("type" := Json.string)
        `andThen` (decodeMsgWithType noOp channels)


decodeMsgWithType : msg -> List (Channel a msg) -> String -> Decoder msg
decodeMsgWithType noOp channels msgType =
    case msgType of
        "ping" ->
            Json.succeed noOp

        "confirm_subscription" ->
            channelNameDecoder
                `andThen`
                    \channelName ->
                        case findMatchingChannel channelName channels of
                            Just channel ->
                                Json.succeed channel.onConnect

                            Nothing ->
                                Json.succeed noOp

        "reject_subscription" ->
            channelNameDecoder
                `andThen`
                    \channelName ->
                        case findMatchingChannel channelName channels of
                            Just channel ->
                                Json.succeed channel.onReject

                            Nothing ->
                                Json.succeed noOp

        _ ->
            Json.succeed noOp


channelNameDecoder : Decoder String
channelNameDecoder =
    Json.decodeString ("channel" := Json.string)
        |> Json.customDecoder ("identifier" := Json.string)


findMatchingChannel : String -> List (Channel a msg) -> Maybe (Channel a msg)
findMatchingChannel channelName channels =
    case channels of
        [] ->
            Nothing

        head :: rest ->
            if head.name == channelName then
                Just head
            else
                findMatchingChannel channelName rest
