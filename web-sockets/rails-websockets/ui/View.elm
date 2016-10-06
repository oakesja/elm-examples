module View exposing (view, Config)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Model exposing (..)


type alias Config msg =
    { sendMsgToAll : msg
    , sendMsgToSelf : msg
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
        [ eventsView "all messages" model.allStatus model.allEvents config.sendMsgToAll
        , eventsView "personal messages" model.personalStatus model.personalEvents config.sendMsgToSelf
        ]


eventsView : String -> Status -> List Event -> msg -> Html msg
eventsView name status events sendMsg =
    case status of
        Connected ->
            div
                []
                [ text <| "Currently connected to " ++ name
                , div [] <|
                    List.map eventView events
                , button
                    [ onClick sendMsg ]
                    [ text "send" ]
                ]

        Disconnected ->
            text <| "Currently disconnected from " ++ name


eventView : Event -> Html msg
eventView event =
    div []
        [ text <| event.userId ++ " - " ++ event.msg ]
