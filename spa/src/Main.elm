module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (style)
import Navigation exposing (Location)
import String


type Page
    = Page1
    | Page2
    | Page3
    | NotFound


type alias Model =
    { currentPage : Page
    }


init : Page -> ( Model, Cmd Msg )
init page =
    { currentPage = page } ! []


type Msg
    = GoToPage Page


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GoToPage page ->
            model ! [ Navigation.newUrl (pageToUrl page) ]


urlUpdate : Page -> Model -> ( Model, Cmd Msg )
urlUpdate page model =
    { model | currentPage = page } ! []


pageToUrl : Page -> String
pageToUrl page =
    case page of
        Page1 ->
            "#page1"

        Page2 ->
            "#page2"

        Page3 ->
            "#page3"

        NotFound ->
            ""


locationToPage : Location -> Page
locationToPage location =
    case String.dropLeft 1 location.hash of
        "page1" ->
            Page1

        "page2" ->
            Page2

        "page3" ->
            Page3

        _ ->
            NotFound


urlParser : Navigation.Parser Page
urlParser =
    Navigation.makeParser locationToPage


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            ]
        ]
        [ toString model.currentPage
            |> (++) "Currently on "
            |> text
        , navButtons
        ]


navButtons : Html Msg
navButtons =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "row" )
            ]
        ]
        [ button [ onClick (GoToPage Page1) ] [ text "Page 1" ]
        , button [ onClick (GoToPage Page2) ] [ text "Page 2" ]
        , button [ onClick (GoToPage Page3) ] [ text "Page 3" ]
        ]


main : Program Never
main =
    Navigation.program urlParser
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }
