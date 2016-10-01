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
        [ msgsView "all messages" model.allStatus model.allMsgs config.sendMsgToAll
        , msgsView "personal messages" model.personalStatus model.personalMsgs config.sendMsgToSelf
        ]


msgsView : String -> Status -> List Message -> msg -> Html msg
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


msgView : Message -> Html msg
msgView msg =
    div []
        [ text <| msg.userId ++ " - " ++ msg.msg ]
