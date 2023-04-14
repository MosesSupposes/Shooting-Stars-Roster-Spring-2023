module Roster exposing (Jersey, Player, Position, Role(..), currentRoster, jerseyToString, maybeRoleToString, positionToRole, positionToString, roleToPosition, roleToString)


type Role
    = PG
    | SG
    | SF
    | PF
    | C
    | Coach


type alias Position =
    Maybe Int


type alias Jersey =
    Maybe Int


roleToPosition : Role -> Position
roleToPosition role =
    case role of
        PG ->
            Just 1

        SG ->
            Just 2

        SF ->
            Just 3

        PF ->
            Just 4

        C ->
            Just 5

        Coach ->
            Nothing


positionToRole : Position -> Role
positionToRole position =
    case position of
        Just 1 ->
            PG

        Just 2 ->
            SG

        Just 3 ->
            SF

        Just 4 ->
            PF

        Just 5 ->
            C

        _ ->
            Coach


roleToString : Role -> String
roleToString role =
    case role of
        PG ->
            "PG"

        SG ->
            "SG"

        SF ->
            "SF"

        PF ->
            "PF"

        C ->
            "C"

        Coach ->
            "Coach"


maybeRoleToString : Maybe Role -> String
maybeRoleToString mrole =
    case mrole of
        Just role ->
            roleToString role

        Nothing ->
            "N/A"


positionToString : Position -> String
positionToString position =
    case position of
        Just pos ->
            String.fromInt pos

        Nothing ->
            "Coach"


jerseyToString : Jersey -> String
jerseyToString jersey =
    case jersey of
        Just jrsy ->
            String.fromInt jrsy

        Nothing ->
            "N/A"


type alias Player =
    { name : String, jerseyNumber : Maybe Int, phoneNumber : String, primaryRole : Role, backupRole : Maybe Role }


currentRoster : List Player
currentRoster =
    [
    , { name = "Michael", jerseyNumber = Just 6, phoneNumber = "(612) 986-5405", primaryRole = SF, backupRole = Just SG }
    , { name = "Moses", jerseyNumber = Just 8, phoneNumber = "(929) 389-7608", primaryRole = SF, backupRole = Just PF }
    ]
