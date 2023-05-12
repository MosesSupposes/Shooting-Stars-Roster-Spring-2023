module Login exposing (Model(..), update, view)

import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)
import Roster exposing (Player)



-- MODEL


type alias Attempts =
    Int


type alias ExistingPlayerCredentials =
    { name : String, jersey : String }


type alias ExistingRoster =
    List Player


type Model
    = AttemptingToLogin Attempts ExistingPlayerCredentials ExistingRoster
    | HasLoggedIn


type UpdateExistingPlayerCredentials
    = InputExistingPlayerName String
    | InputExistingPlayerJersey String



-- UPDATE


type Msg
    = LoginAttempt Attempts ExistingPlayerCredentials
    | UpdateExistingPlayerCredentials


update : Msg -> Model -> Model
update msg model =
    case msg of
        LoginAttempt attempts existingPlayerCreds ->
            case model of
                AttemptingToLogin _ _ existingRoster ->
                    let
                        getCreds : List Player -> List ExistingPlayerCredentials
                        getCreds roster =
                            List.map (\player -> ExistingPlayerCredentials player.name (Maybe.withDefault "0" player.jerseyNumber)) roster
                    in
                    if List.member existingPlayerCreds (getCreds existingRoster) then
                        HasLoggedIn

                    else
                        AttemptingToLogin (attempts + 1) { name = "", jersey = "" } existingRoster



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        AttemptingToLogin numOfAttempts existingPlayer _ ->
            if numOfAttempts <= 3 then
                form [ onClick (LoginAttempt (numOfAttempts + 1) existingPlayer) ]
                    [ input [ onInput InputExistingPlayerName ] [ value existingPlayer.name ]
                    , input [ onInput InputExistingPlayerJersey ] [ value existingPlayer.jersey ]
                    ]

            else
                div [] [ text ("Sorry, you can't view our roster for security purposes. Try again in " ++ timeoutBasedOnAttempts numOfAttempts ++ "seconds.") ]



-- TODO: Start timer


timeoutBasedOnAttempts : Int -> String
timeoutBasedOnAttempts numOfAttempts =
    numOfAttempts |> (\x -> x * 1000) >> (\x -> x // 60) >> String.fromInt
