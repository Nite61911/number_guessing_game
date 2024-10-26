#!/bin/bash

# variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# prompt player for username
echo "Enter your username:"
read USERNAME

# get username data
USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if player is not found
if [[ -z $USERNAME_RESULT ]]; then
    # greet player
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    
    # add player to database
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
    # get the number of games played and the best game (fewest guesses)
    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID_RESULT")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID_RESULT")
    
    # greet returning player with stats
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
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
    # increment guess count before validation to start count at 1
    ((GUESS_COUNT++))
    
    # check if input is a valid integer
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
    elif [[ $USER_GUESS -gt 1000 || $USER_GUESS -lt 1 ]]; then
        echo "That is not a valid number between 1 and 1000, guess again:"
    else
        # check inequalities and give hints
        if [[ $USER_GUESS -lt $SECRET_NUMBER ]]; then
            echo "It's higher than that, guess again:"
        else
            echo "It's lower than that, guess again:"
        fi
    fi
    read USER_GUESS
done

# increment guess count for the final correct guess
((GUESS_COUNT++))

# add result to game history/database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, guesses) VALUES ($USER_ID_RESULT, $SECRET_NUMBER, $GUESS_COUNT)")

# winning message
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
