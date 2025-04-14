#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
  # Get team name - WINNER
  if [[ $WINNER != "winner" ]]; then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    
    # If team not found
    if [[ -z $TEAM_ID ]]; then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted into teams: $WINNER"
      fi
    fi
  fi

  # Get team name - OPPONENT
  if [[ $OPPONENT != "opponent" ]]; then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    
    # If team not found
    if [[ -z $TEAM_ID ]]; then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted into teams: $OPPONENT"
      fi
    fi
  fi
  #insert gama data
  if [[ $YEAR != "year" && $ROUND != "round" && $WINNER != "winner" && $OPPONENT != "opponent" && $WINNER_GOALS != "winner_goals" && $OPPONENT_GOALS != "opponent_goals" ]]; then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    
    # Check if the game already exists
    GAME_EXISTS=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID;")

    if [[ -z $GAME_EXISTS ]]; then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
      
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted into games: $YEAR $ROUND - $WINNER vs $OPPONENT"
      fi
    fi
  fi
done

