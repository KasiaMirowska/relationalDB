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

  if [[ $YEAR != "year" || $ROUND != "round" ]]; then
    YEAR_DB=$($PSQL "SELECT year FROM games WHERE year='$YEAR';")
    ROUND_DB=$($PSQL "SELECT round FROM games WHERE round='$ROUND';")
    
    
    if [[ -z $YEAR_DB && -z $ROUND_DB]]; then
      INSERT_YEAR_RESULT=$($PSQL "INSERT INTO games(year) VALUES('$YEAR')")
      INSERT_ROUND_RESULT=$($PSQL "INSERT INTO games(round) VALUES('$ROUND')")
      if [[ $INSERT_YEAR_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted into games: $YEAR , $ROUND"
      fi
    fi

    
  fi
done

