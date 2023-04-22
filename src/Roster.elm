module Roster exposing (Jersey, Player, Position, Role(..), jerseyToString, maybeRoleToRole, maybeRoleToString, playerDecoder, playerEncoder, positionToRole, positionToString, roleToPosition, roleToString, rosterDecoder, stringToMaybeRole)

import Json.Decode as Decode
import Json.Encode as Encode


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
    Maybe String


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


stringToMaybeRole : String -> Maybe Role
stringToMaybeRole role =
    case String.toUpper role of
        "PG" ->
            Just PG

        "SG" ->
            Just SG

        "SF" ->
            Just SF

        "PF" ->
            Just PF

        "C" ->
            Just C

        "COACH" ->
            Just Coach

        _ ->
            Nothing


maybeRoleToRole : Maybe Role -> Role
maybeRoleToRole role =
    case role of
        Just r ->
            r

        Nothing ->
            Coach


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
            jrsy

        Nothing ->
            "N/A"


type alias Player =
    { name : String, jerseyNumber : Maybe String, phoneNumber : String, primaryRole : Role, backupRole : Maybe Role }



-- DECODE


roleDecoder : Decode.Decoder Role
roleDecoder =
    Decode.string
        |> Decode.map
            (\str ->
                case str of
                    "PG" ->
                        PG

                    "SG" ->
                        SG

                    "SF" ->
                        SF

                    "PF" ->
                        PF

                    "C" ->
                        C

                    "Coach" ->
                        Coach

                    _ ->
                        Coach
            )


playerDecoder : Decode.Decoder Player
playerDecoder =
    Decode.map5 Player
        (Decode.field "name" Decode.string)
        (Decode.field "jerseyNumber" (Decode.maybe Decode.string))
        (Decode.field "phoneNumber" Decode.string)
        (Decode.field "primaryRole" roleDecoder)
        (Decode.field "backupRole" (Decode.maybe roleDecoder))


rosterDecoder : Decode.Decoder (List Player)
rosterDecoder =
    Decode.list playerDecoder



-- ENCODE


playerEncoder : Maybe Player -> Encode.Value
playerEncoder player =
    case player of
        Just p ->
            Encode.object
                [ ( "name", Encode.string p.name )
                , ( "jerseyNumber", Encode.string (jerseyToString p.jerseyNumber) )
                , ( "primaryRole", Encode.string (roleToString p.primaryRole) )
                , ( "backupRole", Encode.string (maybeRoleToString p.backupRole) )
                , ( "phoneNumber", Encode.string p.phoneNumber )
                ]

        Nothing ->
            Encode.null
