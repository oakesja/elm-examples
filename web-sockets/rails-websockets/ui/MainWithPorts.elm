port module MainWithPorts exposing (main)

import Html.App
import Model exposing (..)
import View exposing (..)


type Msg
    = ConnectedTo
    | DisconnectedFrom
    | ReceivedEvent Event
    | SendMsg


init : ( Model, Cmd Msg )
init =
    Model.init ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnectedTo ->
            { model | status = Connected } ! []

        DisconnectedFrom ->
            { model | status = Disconnected } ! []

        ReceivedEvent event ->
            { model | events = model.events ++ [ event ] } ! []

        SendMsg ->
            model ! [ sendMsg () ]


port connected : (String -> msg) -> Sub msg


port disconnected : (String -> msg) -> Sub msg


port receiveEvent : (Event -> msg) -> Sub msg


port sendMsg : () -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ connected (\_ -> ConnectedTo)
        , disconnected (\_ -> DisconnectedFrom)
        , receiveEvent ReceivedEvent
        ]


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view { sendMsg = SendMsg }
        }
