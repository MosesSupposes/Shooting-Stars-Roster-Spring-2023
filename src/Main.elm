module Main exposing (main)

import Browser
import Html exposing (..)
import Roster exposing (Player, currentRoster)


type alias Model =
    { roster : List Player }


type Msg
    = AddPlayerToRoster Player
    | RemovePlayerFromRoster Player
    | EditPlayerInfo Player


init : () -> ( Model, Cmd msg )
init _ =
    ( { roster = currentRoster }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        headers =
            [ "Name", "Jersey", "Role", "Backup Role", "Phone #" ]

        viewHeader header =
            th [] [ text header ]
    in
    { title = "Shooting Starts Roster | Spring Basketball 2023"
    , body =
        [ table []
            [ tr [] (List.map viewHeader headers)
            , tr [] (List.concatMap viewPlayer model.roster)
            ]
        ]
    }


viewPlayer : Player -> List (Html Msg)
viewPlayer player =
    [ td [] [ text player.name ]
    , td []
        [ text (Roster.jerseyToString player.jerseyNumber) ]
    , td [] [ text (player.primaryRole |> Roster.roleToString) ]
    , td [] [ text (player.backupRole |> Roster.maybeRoleToString) ]
    , td [] [ text player.phoneNumber ]
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document { init = init, view = view, update = update, subscriptions = subscriptions }
