#!/bin/bash

# variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# prompt player for username
echo -e "\nEnter your username:"
read USERNAME

# get username data
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if player is not found
if [[ -z $USERNAME_RESULT ]]; then
    # greet player
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    
    # add player to database
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID_RESULT")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID_RESULT")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

# generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# variable to store number of guesses/tries
GUESS_COUNT=0

# prompt first guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

# loop to prompt user to guess until correct
until [[ $USER_GUESS -eq $SECRET_NUMBER ]]; do
    # check if input is a valid integer
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
        echo -e "\nThat is not an integer, guess again:"
    elif [[ $USER_GUESS -gt 1000 || $USER_GUESS -lt 1 ]]; then
        echo -e "\nThat is not a valid number between 1 and 1000, guess again:"
    else
        # increment guess count and check inequalities to give hints
        ((GUESS_COUNT++))
        if [[ $USER_GUESS -lt $SECRET_NUMBER ]]; then
            echo "It's higher than that, guess again:"
        else
            echo "It's lower than that, guess again:"
        fi
    fi
    read USER_GUESS
done

# increment for the final correct guess
((GUESS_COUNT++))

# add result to game history/database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, guesses) VALUES ($USER_ID_RESULT, $SECRET_NUMBER, $GUESS_COUNT)")

# winning message
echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
