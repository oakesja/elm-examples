module MainWithSockets exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)
import RailsWebSocket exposing (Channel)
import Json.Decode as Json exposing (Decoder, (:=))


type Msg
    = ConnectedToAllChannel
    | ConnectedToPersonalChannel
    | RejectedFromAllChannel
    | RejectedFromPersonalChannel
    | EventFromAllChannel Event
    | EventFromPersonalChannel Event
    | SendMsgToAll
    | SendMsgToSelf
    | NoOp


init : ( Model, Cmd Msg )
init =
    { allStatus = Disconnected
    , personalStatus = Disconnected
    , allEvents = []
    , personalEvents = []
    }
        ! [ RailsWebSocket.connect socketUrl allChannel
          , RailsWebSocket.connect socketUrl personalChannel
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnectedToAllChannel ->
            { model | allStatus = Connected } ! []

        ConnectedToPersonalChannel ->
            { model | personalStatus = Connected } ! []

        RejectedFromAllChannel ->
            { model | allStatus = Disconnected } ! []

        RejectedFromPersonalChannel ->
            { model | personalStatus = Disconnected } ! []

        EventFromAllChannel event ->
            { model | allEvents = model.allEvents ++ [ event ] } ! []

        EventFromPersonalChannel event ->
            { model | personalEvents = model.personalEvents ++ [ event ] } ! []

        SendMsgToAll ->
            model ! [ RailsWebSocket.perform socketUrl "sendMessage" allChannel ]

        SendMsgToSelf ->
            model ! [ RailsWebSocket.perform socketUrl "sendMessage" personalChannel ]

        NoOp ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    RailsWebSocket.listen socketUrl
        NoOp
        [ allChannel
        , personalChannel
        ]


socketUrl : String
socketUrl =
    "ws://localhost:3000/cable"


allChannel : Channel Event Msg
allChannel =
    { name = "AllMessagesChannel"
    , onConnect = ConnectedToAllChannel
    , onReject = RejectedFromAllChannel
    , onMessage = EventFromAllChannel
    , messageDecoder = eventDecoder
    }


personalChannel : Channel Event Msg
personalChannel =
    { name = "PersonalMessagesChannel"
    , onConnect = ConnectedToPersonalChannel
    , onReject = RejectedFromPersonalChannel
    , onMessage = EventFromPersonalChannel
    , messageDecoder = eventDecoder
    }


eventDecoder : Decoder Event
eventDecoder =
    Json.object2 Event
        ("userId" := Json.string)
        ("msg" := Json.string)


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
