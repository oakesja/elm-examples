module View exposing (view, Config)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Model exposing (..)


type alias Config msg =
    { sendMsg : msg
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
        [ eventsView config model
        ]


eventsView : Config msg -> Model -> Html msg
eventsView config model =
    case model.status of
        Connected ->
            div
                []
                [ text "Currently connected to channel"
                , div [] <|
                    List.map eventView model.events
                , button
                    [ onClick config.sendMsg ]
                    [ text "send" ]
                ]

        Disconnected ->
            text "Currently disconnected from channel"


eventView : Event -> Html msg
eventView event =
    div []
        [ text <| event.userId ++ " - " ++ event.action ]
