port module Main exposing (main)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Html.App


type Status
    = Connected
    | Disconnected


type alias Message =
    { userId : String
    , msg : String
    }


type alias Model =
    { allStatus : Status
    , personalStatus : Status
    , allMsgs : List Message
    , personalMsgs : List Message
    }


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


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "justify-content", "space-around" )
            ]
        ]
        [ msgsView "all messages" model.allStatus model.allMsgs SendMsgToAll
        , msgsView "personal messages" model.personalStatus model.personalMsgs SendMsgToSelf
        ]


msgsView : String -> Status -> List Message -> Msg -> Html Msg
msgsView name status msgs sendMsg =
    case status of
        Connected ->
            div
                []
                [ text <| "Currently connected to " ++ name
                , div [] <|
                    List.map msgView msgs
                , button
                    [ onClick sendMsg ]
                    [ text "send" ]
                ]

        Disconnected ->
            text <| "Currently disconnected from " ++ name


msgView : Message -> Html Msg
msgView msg =
    div []
        [ text <| msg.userId ++ " - " ++ msg.msg ]


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
        , view = view
        }
