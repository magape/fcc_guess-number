#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align --tuples-only -c"

## generate random number in range 1 - 1000 and store in secret_number variable
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
#echo "The secret number is: $SECRET_NUMBER"

# who is playing?
## get username
echo "Enter your username:"
read  USERNAME

## query database about username
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
## if username not in database
then
  ###  display message for new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ###  add new username to database
  INSERT_NEW_USERNAME=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  ### get user_id for added username
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  ### initialize variables for new user
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
## if username in database
else
  ### get number of games and best game for user 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  ### display message for (old) user
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# game initialization
## display task
echo "Guess the secret number between 1 and 1000:"
## get the player guess (guessed_number)
read GUESSED_NUMBER

# continue to ask for a number if the user input is not a number
while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
do 
  echo "That is not an integer, guess again:"
  read GUESSED_NUMBER
done
NUMBER_OF_GUESSES=1

# while the player does not guess the number
while [[ $GUESSED_NUMBER != $SECRET_NUMBER ]]
do
  if (( $SECRET_NUMBER < $GUESSED_NUMBER ))
  then
    #####  display guessed_numbered < secret_number
    echo "It's lower than that, guess again:"
  else
    ##### display guessed_number > secret_number
    echo "It's higher than that, guess again:"
  fi
  ## get the player new guess (guessed_number)
  read GUESSED_NUMBER
  ## check if player input is not a number
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  ### if player input is not a number then  display message
  then
    echo "That is not an integer, guess again:"
    ### if player input is a number
  else
    #### update (increment) number_of_guesses
    (( NUMBER_OF_GUESSES++ ))
  fi
done

# update database after the end of game
## update number of games_played
(( GAMES_PLAYED++ ))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")
## if the result is better than the best game
#test#echo $BEST_GAME
if (( $BEST_GAME > $NUMBER_OF_GUESSES ))
then
  ### update the best_game
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID")
fi
# display the message before ending the game
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"