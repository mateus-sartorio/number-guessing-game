#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"

read USERNAME

QUERY_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")

if [[ -z $QUERY_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  CREATE_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  read GAMES_PLAYED PIPE BEST_GAME <<< $QUERY_RESULT
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

GENERATE_SECRET_NUMBER() {
  echo $((RANDOM % 1000 + 1))
}

SECRET_NUMBER=$(GENERATE_SECRET_NUMBER)

NUMBER_OF_GUESSES=0

MAIN_LOOP() {
  read GUESS

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    MAIN_LOOP
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    MAIN_LOOP
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    MAIN_LOOP
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    GAMES_PLAYED=$((GAMES_PLAYED + 1))

    if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
    then
      BEST_GAME=$NUMBER_OF_GUESSES
    fi
    
    UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
  fi
}

MAIN_LOOP