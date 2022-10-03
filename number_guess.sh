#!/bin/bash
# Number Guessing Game

# PSQL variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# ask for username
echo "Enter your username:"
read USERNAME
# check if the username exists in the database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
# if not found
if [[ -z $USER_ID ]]
then
  # display welcome message
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  # get user_id of new user
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # get username info
  USERNAME_INFO=$($PSQL "SELECT COUNT(*), MIN(number_of_guess) 
                         FROM games WHERE user_id=$USER_ID")
  echo "$USERNAME_INFO" | while IFS="|" read GAME_PLAYED BEST_GAME
  do
  # display welcome message
  echo -e "\nWelcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
# generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1001 ))
# start the game
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS_NUMBER
# start counting the number of guess
NUMBER_OF_GUESSES=1
while [[ $GUESS_NUMBER != $SECRET_NUMBER ]]
do
  # check if it is not an integer
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS_NUMBER
  else
    # check if guess number is higher than number
    if [[ $GUESS_NUMBER > $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      read GUESS_NUMBER
      NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
    else
      echo -e "\nIt's higher than that, guess again:"
      read GUESS_NUMBER
      NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
    fi
  fi  
done
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
# add data to database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guess) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
