module Login exposing (Model(..), Msg(..), update, view)

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


type PlayerCredentialsUpdateValue
    = InputExistingPlayerName String
    | InputExistingPlayerJersey String



-- UPDATE


type Msg
    = LoginAttempt Attempts ExistingPlayerCredentials
    | UpdateExistingPlayerCredentials PlayerCredentialsUpdateValue


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

                HasLoggedIn ->
                    HasLoggedIn

        UpdateExistingPlayerCredentials updateValue ->
            case model of
                AttemptingToLogin attempts existingPlayerCreds existingRoster ->
                    case updateValue of
                        InputExistingPlayerName name ->
                            AttemptingToLogin attempts { existingPlayerCreds | name = name } existingRoster

                        InputExistingPlayerJersey jersey ->
                            AttemptingToLogin attempts { existingPlayerCreds | jersey = jersey } existingRoster

                HasLoggedIn ->
                    HasLoggedIn



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        AttemptingToLogin numOfAttempts existingPlayer _ ->
            if numOfAttempts <= 3 then
                form [ onClick (LoginAttempt (numOfAttempts + 1) existingPlayer) ]
                    [ input [ onInput (\name -> UpdateExistingPlayerCredentials (InputExistingPlayerName name)), value existingPlayer.name ] [ text existingPlayer.name ]
                    , input [ onInput (\jersey -> UpdateExistingPlayerCredentials (InputExistingPlayerJersey jersey)), value existingPlayer.jersey ] [ text existingPlayer.jersey ]
                    ]

            else
                div [] [ text ("Sorry, you can't view our roster for security purposes. Try again in " ++ timeoutBasedOnAttempts numOfAttempts ++ " seconds.") ]

        HasLoggedIn ->
            div [] [ p [] [ text "Welcome back, Star.\nLoading Roster..." ] ]



-- TODO: Start timer


timeoutBasedOnAttempts : Int -> String
timeoutBasedOnAttempts numOfAttempts =
    numOfAttempts |> (\x -> x * 1000) >> (\x -> x // 60) >> String.fromInt
