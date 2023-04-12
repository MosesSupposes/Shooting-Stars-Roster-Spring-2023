module Roster exposing (Player, Role(..), currentRoster, positionToRole, roleToPosition)


type Role
    = PG
    | SG
    | SF
    | PF
    | C
    | Coach


roleToPosition : Role -> Maybe Int
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


positionToRole : Maybe Int -> Role
positionToRole role =
    case role of
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


type alias Player =
    { name : String, jerseyNumber : Maybe Int, phoneNumber : String, primaryRole : Role, backupRole : Maybe Role }


currentRoster : List Player
currentRoster =
    [ { name = "Coach Wavy", jerseyNumber = Nothing, phoneNumber = "(651) 353-7163", primaryRole = Coach, backupRole = Nothing }
    , { name = "Michael", jerseyNumber = Just 6, phoneNumber = "(612) 986-5405", primaryRole = SF, backupRole = Just SG }
    , { name = "Moses", jerseyNumber = Just 8, phoneNumber = "(929) 389-7608", primaryRole = SF, backupRole = Just PF }
    ]
