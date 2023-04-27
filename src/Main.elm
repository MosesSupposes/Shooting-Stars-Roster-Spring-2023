module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onDoubleClick, onInput, onSubmit)
import Http
import Roster exposing (Player, Role(..), deletePlayerDecoder, jerseyToString, maybeRoleToRole, maybeRoleToString, playerDecoder, playerEncoder, roleToString, rosterDecoder, stringToMaybeRole)
import Swiper


type alias ErrorMessage =
    String


type Model
    = ViewingRoster Swiper.SwipingState (List Player)
    | AddingNewTeammate (List Player) (Maybe Player)
    | ErrorScreen (List Player) ErrorMessage



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
    | AttemptToRemovePlayerFromRoster Player (Maybe Swiper.SwipeEvent)
    | RemovedPlayerFromRoster (Result Http.Error String)
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
                    ( ViewingRoster Swiper.initialSwipingState fullRoster, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ViewNewTeammateForm ->
            case model of
                ViewingRoster _ currentRoster ->
                    ( AddingNewTeammate currentRoster Nothing, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        -- TODO: Make the player's jersey be their UUID
        AttemptToRemovePlayerFromRoster player maybeSwipeEvent ->
            case model of
                ViewingRoster swipingState currentRoster ->
                    let
                        url =
                            case player.jerseyNumber of
                                Just num ->
                                    baseUrlDev ++ "/" ++ num

                                Nothing ->
                                    baseUrlDev ++ "/" ++ "000"

                        ( newSwipeState, swipedLeft ) =
                            case maybeSwipeEvent of
                                Just swipeEvent ->
                                    Swiper.hasSwipedLeft swipeEvent swipingState

                                Nothing ->
                                    ( swipingState, False )

                        removePlayerIfSwiped didSwipeLeft roster =
                            if didSwipeLeft then
                                List.filter (\p -> not (p == player)) currentRoster

                            else
                                roster

                        -- This query param will fail the operation; no player record will contain this jersey number
                    in
                    -- TODO: Swap out the dev url with prod
                    ( ViewingRoster newSwipeState (removePlayerIfSwiped swipedLeft currentRoster)
                    , Http.request
                        { method = "DELETE"
                        , headers = []
                        , url = url
                        , expect = Http.expectString RemovedPlayerFromRoster
                        , body = Http.emptyBody
                        , timeout = Nothing
                        , tracker = Nothing
                        }
                    )

                _ ->
                    ( model, Cmd.none )

        RemovedPlayerFromRoster response ->
            case ( response, model ) of
                ( Ok xRowsDeleted, ViewingRoster currentSwipeState currentRoster ) ->
                    let
                        failureMessage =
                            "There was an issue removing this player from the roster. Refresh the page and ry again."
                    in
                    case String.toInt xRowsDeleted of
                        Just rowsDeletedAsInt ->
                            if rowsDeletedAsInt > 0 then
                                -- The player should already be removed from the roster in this view. See the return value of the AttemptToRemovePlayerFromRoster case.
                                ( ViewingRoster currentSwipeState currentRoster, Cmd.none )

                            else
                                ( ErrorScreen currentRoster failureMessage, Cmd.none )

                        Nothing ->
                            ( ErrorScreen currentRoster failureMessage, Cmd.none )

                -- This handles the case where we are on a different view from `ViewingRoster`, but the delete request was successful (this shouldn't happen, but we handle it anyways.)
                ( Ok _, _ ) ->
                    ( model, Cmd.none )

                ( Err error, ViewingRoster _ currentRoster ) ->
                    case error of
                        Http.BadUrl errMsg ->
                            ( ErrorScreen currentRoster ("Bad URL: " ++ errMsg ++ ". Try agian."), Cmd.none )

                        Http.Timeout ->
                            ( ErrorScreen currentRoster "The request timed out. Try again", Cmd.none )

                        Http.NetworkError ->
                            ( ErrorScreen currentRoster "There was a network error. Check your internet connection and try again.", Cmd.none )

                        Http.BadStatus status ->
                            case String.fromInt status |> String.left 1 of
                                -- 4xx error
                                "4" ->
                                    ( ErrorScreen currentRoster "The server could not fulfill your request. Modify it to the best of your intuition and try again.", Cmd.none )

                                -- 5xx error
                                "5" ->
                                    ( ErrorScreen currentRoster "The server is dealing with some issues. Please try again at a later time.", Cmd.none )

                                -- xxx error
                                _ ->
                                    ( ErrorScreen currentRoster "Something weird is going on... Refresh this browser window and try again.", Cmd.none )

                        Http.BadBody _ ->
                            ( ErrorScreen currentRoster "You only need to specify the jersey number of the player you are trying to remove. Do this and try again.", Cmd.none )

                ( Err _, _ ) ->
                    ( model, Cmd.none )

        -- TODO: There should be a separate state, say `EditingTeammateInfo` that renders a form to edit player info; similar to the `AddingNewTeammate` state.
        EditPlayerInfo player ->
            case model of
                ViewingRoster currentSwipeState currentRoster ->
                    ( ViewingRoster currentSwipeState <|
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
                ViewingRoster _ _ ->
                    -- The roster should only be updated when in the `AddingNewTeammate` state
                    ( model, Cmd.none )

                AddingNewTeammate existingRoster (Just newTeammate) ->
                    ( ViewingRoster Swiper.initialSwipingState (newTeammate :: existingRoster)
                    , Http.post
                        { url = baseUrlProd
                        , body = Http.jsonBody (playerEncoder (Just newTeammate))
                        , expect = Http.expectJson AddedPlayerToRoster playerDecoder
                        }
                    )

                AddingNewTeammate _ Nothing ->
                    ( model, Cmd.none )

                ErrorScreen _ _ ->
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
                    ( ViewingRoster Swiper.initialSwipingState (newTeammate :: existingRoster), Cmd.none )

                ( AddingNewTeammate existingRoster _, Err _ ) ->
                    ( ViewingRoster Swiper.initialSwipingState existingRoster, Cmd.none )

                ( _, _ ) ->
                    ( model, Cmd.none )


baseUrlDev : String
baseUrlDev =
    "http://localhost:4000/api/roster"


baseUrlProd : String
baseUrlProd =
    "https://shooting-stars-spring-2023-be.herokuapp.com/api/roster"


init : () -> ( Model, Cmd Msg )
init _ =
    ( ViewingRoster Swiper.initialSwipingState [], Http.get { url = baseUrlProd, expect = Http.expectJson ViewRoster rosterDecoder } )


view : Model -> Browser.Document Msg
view model =
    { title = "Shooting Starts Roster | Spring Basketball 2023"
    , body =
        case model of
            ViewingRoster _ roster ->
                [ main_ [ id "app-container" ]
                    [ appTitle
                    , div [ class "crud-controls" ] [ addPlayerBtn ]
                    , table [] (renderTableRows roster)
                    ]
                ]

            AddingNewTeammate _ newTeammateInfo ->
                [ main_ [ id "app-container" ]
                    [ appTitle
                    , backToHome model
                    , addTeammateForm newTeammateInfo
                    ]
                ]

            ErrorScreen roster errorMessage ->
                [ main_ [ id "app-container" ]
                    [ appTitle
                    , div [ class "error-container" ] [ text errorMessage ]
                    , div [ class "crud-controls" ] [ addPlayerBtn ]
                    , table [] (renderTableRows roster)
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
    tr
        ([ onDoubleClick (AttemptToRemovePlayerFromRoster player Nothing) ]
         -- TODO: Fix the error associated with the line of code below
         -- ++ Swiper.onSwipeEvents (AttemptToRemovePlayerFromRoster player (\swipeEvent -> Just swipeEvent))
        )
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
