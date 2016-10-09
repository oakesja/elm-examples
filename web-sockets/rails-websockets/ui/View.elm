module View exposing (view, Config)

import Html exposing (Html, div, text, button, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (style, placeholder)
import Model exposing (..)


type alias Config msg =
    { sendMsg : msg
    , onInput : String -> msg
    , disconnect : msg
    , connect : msg
    }


view : Config msg -> Model -> Html msg
view config model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "justify-content", "space-around" )
            ]
        ]
        [ eventsView model
        , controls config model
        ]


eventsView : Model -> Html msg
eventsView model =
    case model.status of
        Connected ->
            div
                []
                [ text "Connected to channel"
                , div [] <|
                    List.map eventView model.events
                ]

        Disconnected ->
            text "Disconnected from channel"


eventView : Event -> Html msg
eventView event =
    div []
        [ text <| event.userId ++ " - " ++ event.action ++ " " ++ event.msg ]


controls : Config msg -> Model -> Html msg
controls config model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            ]
        ]
        [ input [ placeholder "Input Message", onInput config.onInput ] []
        , button [ onClick config.sendMsg ] [ text "Send Message" ]
        , connectionButton config model
        ]


connectionButton : Config msg -> Model -> Html msg
connectionButton config model =
    case model.status of
        Connected ->
            button [ onClick config.disconnect ] [ text "Disconnect From Channel" ]

        Disconnected ->
            button [ onClick config.connect ] [ text "Connect To Channel" ]
