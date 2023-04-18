module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Roster exposing (Player, jerseyToString, rosterDecoder)


type alias Model =
    { roster : List Player, error : String }



-- TODO: Wrap the other CRUD operations in the Result type


type Msg
    = ViewRoster (Result Http.Error (List Player))
    | AddPlayerToRoster Player
    | RemovePlayerFromRoster Player
    | EditPlayerInfo Player


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ViewRoster response ->
            case response of
                Ok fullRoster ->
                    ( { model | roster = fullRoster }, Cmd.none )

                Err httpError ->
                    case httpError of
                        Http.BadBody badBodyMsg ->
                            ( { model | error = badBodyMsg }, Cmd.none )

                        Http.BadUrl url ->
                            ( { model | error = "Bad url (" ++ url ++ ")" }, Cmd.none )

                        Http.Timeout ->
                            ( { model | error = "There was a timeout." }, Cmd.none )

                        Http.BadStatus status ->
                            ( { model | error = "The request failed with a status code of " ++ String.fromInt status }, Cmd.none )

                        Http.NetworkError ->
                            ( { model | error = "There was a network error" }, Cmd.none )

        AddPlayerToRoster player ->
            ( { model | roster = player :: model.roster }, Cmd.none )

        RemovePlayerFromRoster player ->
            ( { model | roster = List.filter (\p -> not (p == player)) model.roster }, Cmd.none )

        EditPlayerInfo player ->
            ( { model
                | roster =
                    List.map
                        (\p ->
                            if p == player then
                                player

                            else
                                p
                        )
                        model.roster
              }
            , Cmd.none
            )


apiUrlDev =
    "http://localhost:4000/api/roster"


apiUrlProd =
    ""


init : () -> ( Model, Cmd Msg )
init _ =
    ( { roster = [], error = "" }, Http.get { url = apiUrlDev, expect = Http.expectJson ViewRoster rosterDecoder } )


view : Model -> Browser.Document Msg
view model =
    { title = "Shooting Starts Roster | Spring Basketball 2023"
    , body =
        [ main_ [ id "app-container" ]
            [ appTitle
            , div [ class "error" ] [ text model.error ]
            , div [ class "crud-controls" ] [ addPlayerBtn, deletePlayerBtn ]
            , table [] (renderTableRows model.roster)
            ]
        ]
    }


renderTableRows : List Player -> List (Html Msg)
renderTableRows roster =
    let
        headers =
            [ "Name", "Jersey", "Role", "Backup Role", "Phone #" ]

        viewHeader header =
            th [] [ text header ]

        helper remainingRoster acc =
            case remainingRoster of
                [] ->
                    List.map viewHeader headers
                        :: acc
                        |> List.concat

                player :: restOfRoster ->
                    helper restOfRoster ([ viewPlayer player ] :: acc)
    in
    helper roster []


viewPlayer : Player -> Html Msg
viewPlayer player =
    tr []
        [ td [] [ text player.name ]
        , td [] [ text (jerseyToString player.jerseyNumber) ]
        , td [] [ text (player.primaryRole |> Roster.roleToString) ]
        , td [] [ text (player.backupRole |> Roster.maybeRoleToString) ]
        , td [] [ text player.phoneNumber ]
        ]


appTitle : Html Msg
appTitle =
    h1 [ class "title" ] [ text "Shooting Stars Roster | Spring 2🏀23" ]


addPlayerBtn : Html Msg
addPlayerBtn =
    button [ class "add-player-btn" ] [ text "+" ]


deletePlayerBtn : Html Msg
deletePlayerBtn =
    button [ class "delete-player-btn" ] [ text "-" ]


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document { init = init, view = view, update = update, subscriptions = subscriptions }
