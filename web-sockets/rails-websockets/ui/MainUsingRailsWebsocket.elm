module MainUsingRailsWebsocket exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)
import RailsWebSocket exposing (Channel)
import Json.Decode as Json exposing (Decoder, (:=))
import Json.Encode


type Msg
    = ConnectedTo
    | RejectedFrom
    | ReceivedEvent Event
    | SendMsg
    | NoOp
    | Input String
    | ConnectTo
    | DisconnectFrom


init : ( Model, Cmd Msg )
init =
    Model.init ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnectedTo ->
            { model | status = Connected } ! []

        RejectedFrom ->
            { model | status = Disconnected } ! []

        ReceivedEvent event ->
            { model | events = model.events ++ [ event ] } ! []

        SendMsg ->
            model
                ! [ RailsWebSocket.perform socketUrl
                        channel
                        "sendMessage"
                        [ ( "msg", Json.Encode.string model.msgToSend ) ]
                  ]

        Input msg ->
            { model | msgToSend = msg } ! []

        ConnectTo ->
            model ! [ RailsWebSocket.connect socketUrl channel ]

        DisconnectFrom ->
            { model | status = Disconnected, events = [] }
                ! [ RailsWebSocket.disconnect socketUrl channel ]

        NoOp ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    RailsWebSocket.listen socketUrl NoOp [ channel ]


socketUrl : String
socketUrl =
    "ws://localhost:3000/cable"


channel : Channel Event Msg
channel =
    { name = "AllMessagesChannel"
    , onConnect = ConnectedTo
    , onReject = RejectedFrom
    , onMessage = ReceivedEvent
    , messageDecoder = eventDecoder
    }


eventDecoder : Decoder Event
eventDecoder =
    Json.object3 Event
        ("userId" := Json.string)
        ("msg" := Json.string)
        ("action" := Json.string)


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
