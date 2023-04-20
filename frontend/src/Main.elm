module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Roster exposing (Player, Role(..), jerseyToString, maybeRoleToRole, maybeRoleToString, playerDecoder, playerEncoder, roleToString, rosterDecoder, stringToMaybeRole)


type Model
    = ViewingRoster (List Player)
    | AddingNewTeammate (List Player) (Maybe Player)



-- TODO: Wrap the other CRUD operations in the Result type


type PlayerField
    = Name String
    | JerseyNumber String
    | PrimaryRole String
    | BackupRole String
    | PhoneNumber String


type Msg
    = ViewRoster (Result Http.Error (List Player))
    | ViewNewTeammateForm
    | RemovePlayerFromRoster Player
    | EditPlayerInfo Player
    | AttemptToAddPlayerToRoster Player
    | AddedPlayerToRoster (Result Http.Error Player)
    | AddNewPlayerInfo PlayerField


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ViewRoster response ->
            case response of
                Ok fullRoster ->
                    ( ViewingRoster fullRoster, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ViewNewTeammateForm ->
            case model of
                ViewingRoster currentRoster ->
                    ( AddingNewTeammate currentRoster Nothing, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RemovePlayerFromRoster player ->
            case model of
                ViewingRoster currentRoster ->
                    ( ViewingRoster <| List.filter (\p -> not (p == player)) currentRoster, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        -- TODO: There should be a separate state, say `EditingTeammateInfo` that renders a form to edit player info; similar to the `AddingNewTeammate` state.
        EditPlayerInfo player ->
            case model of
                ViewingRoster currentRoster ->
                    ( ViewingRoster <|
                        List.map
                            (\p ->
                                if p == player then
                                    player

                                else
                                    p
                            )
                            currentRoster
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        AttemptToAddPlayerToRoster player ->
            case model of
                ViewingRoster _ ->
                    -- The roster should only be updated when in the `AddingNewTeammate` state
                    ( model, Cmd.none )

                AddingNewTeammate existingRoster (Just newTeammate) ->
                    ( ViewingRoster (newTeammate :: existingRoster)
                    , Http.post
                        { url = baseUrlProd
                        , body = Http.jsonBody (playerEncoder (Just newTeammate))
                        , expect = Http.expectJson AddedPlayerToRoster playerDecoder
                        }
                    )

                AddingNewTeammate _ Nothing ->
                    ( model, Cmd.none )

        AddNewPlayerInfo maybeNewPlayerInfo ->
            let
                defaultPlayer =
                    { name = ""
                    , jerseyNumber = Just ""
                    , primaryRole = PG
                    , backupRole = Nothing
                    , phoneNumber = ""
                    }
            in
            case ( model, maybeNewPlayerInfo ) of
                ( AddingNewTeammate existingRoster (Just restOfNewPlayerInfo), Name n ) ->
                    ( AddingNewTeammate existingRoster (Just { restOfNewPlayerInfo | name = n }), Cmd.none )

                ( AddingNewTeammate existingRoster Nothing, Name n ) ->
                    ( AddingNewTeammate existingRoster (Just { defaultPlayer | name = n }), Cmd.none )

                ( AddingNewTeammate existingRoster (Just restOfNewPlayerInfo), JerseyNumber jn ) ->
                    ( AddingNewTeammate existingRoster (Just { restOfNewPlayerInfo | jerseyNumber = Just jn }), Cmd.none )

                ( AddingNewTeammate existingRoster Nothing, JerseyNumber jn ) ->
                    ( AddingNewTeammate existingRoster (Just { defaultPlayer | jerseyNumber = Just jn }), Cmd.none )

                ( AddingNewTeammate existingRoster (Just restOfNewPlayerInfo), PrimaryRole pr ) ->
                    ( AddingNewTeammate existingRoster
                        (Just
                            { restOfNewPlayerInfo
                                | primaryRole =
                                    pr |> (stringToMaybeRole >> maybeRoleToRole)
                            }
                        )
                    , Cmd.none
                    )

                ( AddingNewTeammate existingRoster Nothing, PrimaryRole pr ) ->
                    ( AddingNewTeammate existingRoster
                        (Just
                            { defaultPlayer
                                | primaryRole = pr |> (stringToMaybeRole >> maybeRoleToRole)
                            }
                        )
                    , Cmd.none
                    )

                ( AddingNewTeammate existingRoster (Just restOfNewPlayerInfo), BackupRole br ) ->
                    ( AddingNewTeammate existingRoster (Just { restOfNewPlayerInfo | backupRole = br |> stringToMaybeRole }), Cmd.none )

                ( AddingNewTeammate existingRoster Nothing, BackupRole br ) ->
                    ( AddingNewTeammate existingRoster (Just { defaultPlayer | backupRole = br |> stringToMaybeRole }), Cmd.none )

                ( AddingNewTeammate existingRoster (Just restOfNewPlayerInfo), PhoneNumber pn ) ->
                    ( AddingNewTeammate existingRoster (Just { restOfNewPlayerInfo | phoneNumber = pn }), Cmd.none )

                ( AddingNewTeammate existingRoster Nothing, PhoneNumber pn ) ->
                    ( AddingNewTeammate existingRoster (Just { defaultPlayer | phoneNumber = pn }), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        AddedPlayerToRoster response ->
            case ( model, response ) of
                ( AddingNewTeammate existingRoster _, Ok newTeammate ) ->
                    ( ViewingRoster (newTeammate :: existingRoster), Cmd.none )

                ( AddingNewTeammate existingRoster _, Err _ ) ->
                    ( ViewingRoster existingRoster, Cmd.none )

                ( _, _ ) ->
                    ( model, Cmd.none )


baseUrlDev : String
baseUrlDev =
    "http://localhost:4000/api/roster"


baseUrlProd : String
baseUrlProd =
    "https://shooting-stars-spring-2023-backend.netlify.app/api/roster"


init : () -> ( Model, Cmd Msg )
init _ =
    ( ViewingRoster [], Http.get { url = baseUrlProd, expect = Http.expectJson ViewRoster rosterDecoder } )


view : Model -> Browser.Document Msg
view model =
    { title = "Shooting Starts Roster | Spring Basketball 2023"
    , body =
        case model of
            ViewingRoster fullRoster ->
                [ main_ [ id "app-container" ]
                    [ appTitle
                    , div [ class "crud-controls" ] [ addPlayerBtn ]
                    , table [] (renderTableRows fullRoster)
                    ]
                ]

            AddingNewTeammate _ newTeammateInfo ->
                [ main_ [ id "app-container" ]
                    [ appTitle
                    , backToHome model
                    , addTeammateForm newTeammateInfo
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
        , td [] [ text (formatPhoneNumber player.phoneNumber) ]
        ]


appTitle : Html Msg
appTitle =
    h1 [ class "title" ] [ text "Shooting Stars Roster | Spring 2🏀23" ]


addPlayerBtn : Html Msg
addPlayerBtn =
    button [ class "add-player-btn", onClick ViewNewTeammateForm ] [ text "+" ]


deletePlayerBtn : Html Msg
deletePlayerBtn =
    button [ class "delete-player-btn" ] [ text "-" ]


backToHome : Model -> Html Msg
backToHome model =
    case model of
        AddingNewTeammate existingRoster _ ->
            button
                [ class "back-to-home-btn"
                , onClick (ViewRoster (Ok existingRoster))
                ]
                [ text "⬅️  Return to roster" ]

        _ ->
            div [] []



-- This view function will be called when the model is in the state of `AddingNewTeammate`


addTeammateForm : Maybe Player -> Html Msg
addTeammateForm newTeammate =
    let
        viewForm : Player -> Html Msg
        viewForm teammateInfo =
            let
                roles =
                    [ "PG", "SG", "SF", "PF", "C" ]
            in
            Html.form [ class "add-new-player-form", onSubmit (AttemptToAddPlayerToRoster teammateInfo) ]
                [ label []
                    [ text "Name"
                    , input
                        [ placeholder "Name"
                        , value teammateInfo.name
                        , onInput (\name -> Name name |> AddNewPlayerInfo)
                        ]
                        []
                    ]
                , label []
                    [ text "Jersey Number"
                    , input
                        [ placeholder "Jersey Number"
                        , value (jerseyToString teammateInfo.jerseyNumber)
                        , onInput (\jn -> JerseyNumber jn |> AddNewPlayerInfo)
                        ]
                        []
                    ]
                , label []
                    [ text "Primary Role"
                    , select [ onInput (\pr -> PrimaryRole pr |> AddNewPlayerInfo) ]
                        (List.map (\role -> option [ value role ] [ text role ]) roles)
                    ]
                , label []
                    [ text "Backup Role"
                    , select [ onInput (\br -> BackupRole br |> AddNewPlayerInfo) ]
                        (List.map (\role -> option [ value role ] [ text role ]) roles)
                    ]
                , label []
                    [ text "Phone Number"
                    , input
                        [ placeholder "Phone Number"
                        , value teammateInfo.phoneNumber
                        , onInput (\pn -> PhoneNumber pn |> AddNewPlayerInfo)
                        ]
                        []
                    ]
                , button [ class "join-team-btn" ] [ text "Join 💫" ]
                ]
    in
    case newTeammate of
        Just teammateInfo ->
            viewForm teammateInfo

        Nothing ->
            let
                defaultPlayer : Player
                defaultPlayer =
                    { name = "", jerseyNumber = Just "N/A", primaryRole = PG, backupRole = Nothing, phoneNumber = "" }
            in
            viewForm defaultPlayer


formatPhoneNumber : String -> String
formatPhoneNumber pnumber =
    let
        firstThree =
            String.left 3

        middleThree =
            String.left 6 >> String.right 3

        lastFour =
            String.right 4
    in
    "(" ++ firstThree pnumber ++ ") " ++ middleThree pnumber ++ "-" ++ lastFour pnumber


subscriptions : Model -> Sub msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document { init = init, view = view, update = update, subscriptions = subscriptions }
