#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN() {
  echo "Enter your username:"
  read USERNAME

  # Generate a random number between 1 and 1000
  SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))

  # Initialize tries counter
  TRIES=0

  # Check if the user exists in the database
  FOUND_USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")

  if [[ -z $FOUND_USER ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else 
    # Extract existing user data
    IFS="|" read EXISTING_USER GAMES_PLAYED BEST_GAME <<< "$FOUND_USER"
    echo "Welcome back, $EXISTING_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  echo "Guess the secret number between 1 and 1000:"

  while true; do
    read GUESS

    # Check if input is an integer
    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      continue
    fi

    # Convert GUESS to integer and increment tries counter
    ((TRIES++))

    if (( GUESS < SECRET_NUMBER )); then
      echo "It's higher than that, guess again:"
      continue
    elif (( GUESS > SECRET_NUMBER )); then
      echo "It's lower than that, guess again:"
      continue
    else
      echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

      # Update or Insert user data into the database (Suppress output)
      if [[ -z $FOUND_USER ]]; then
        # New user: Insert into database
        $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 1, $TRIES)" >/dev/null
      else
        # Existing user: Increment games_played and update best_game if better
        NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
        if [[ -z $BEST_GAME || $TRIES -lt $BEST_GAME ]]; then
          $PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED, best_game = $TRIES WHERE username = '$USERNAME'" >/dev/null
        else
          $PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED WHERE username = '$USERNAME'" >/dev/null
        fi
      fi

      return  # End function when user wins
    fi
  done
}

MAIN