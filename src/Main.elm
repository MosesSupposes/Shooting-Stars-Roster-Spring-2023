module Main exposing (..)

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


view : Model -> Browser.Document msg
view model =
    { title = "Shooting Starts Roster | Spring Basketball 2023"
    , body = [ table [] [] ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddPlayerToRoster player ->
            ( { model | roster = player :: model.roster }, Cmd.none )

        RemovePlayerFromRoster player ->
            ( { model | roster = List.filter (\p -> p == player) model.roster }, Cmd.none )

        EditPlayerInfo player ->
            ( { model
                | roster =
                    List.map
                        (\p ->
                            if p == player then
                                p

                            else
                                player
                        )
                        model.roster
              }
            , Cmd.none
            )


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none


main =
    Browser.document { init = init, view = view, update = update, subscriptions = subscriptions }
