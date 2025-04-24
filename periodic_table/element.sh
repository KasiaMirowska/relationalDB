#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
PROVIDED=$1

# Function to look up and display the element info by atomic number, symbol or name
GET_INFO() {
  if [[ -z $PROVIDED ]]; then
    echo "Please provide an element as an argument."
    exit 0
  fi

  # If the provided input is an atomic number (i.e., a number)
  if [[ $PROVIDED =~ ^[0-9]+$ ]]; then
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$PROVIDED")
    if [[ -n $NAME ]]; then
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$PROVIDED")
      TYPE=$($PSQL "SELECT types.type FROM types FULL JOIN properties ON properties.type_id = types.type_id WHERE atomic_number=$PROVIDED")
      MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$PROVIDED")
      MELTS=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$PROVIDED")
      BOILS=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$PROVIDED")
      echo "The element with atomic number $PROVIDED is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTS°C and a boiling point of $BOILS°C."
    else
      echo "I could not find that element in the database."
    fi

  # If the provided input is a symbol (1 or 2 letters)
  elif [[ $PROVIDED =~ ^[A-Za-z]{1,2}$ ]]; then
    SYMBOL="$(echo "${PROVIDED:0:1}" | tr '[:lower:]' '[:upper:]')$(echo "${PROVIDED:1:1}" | tr '[:upper:]' '[:lower:]')"

    NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$SYMBOL'")
    if [[ -n $NAME ]]; then
      TYPE=$($PSQL "SELECT types.type FROM elements FULL JOIN properties ON properties.atomic_number = elements.atomic_number JOIN types ON properties.type_id = types.type_id WHERE symbol='$SYMBOL'")
      MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=(SELECT atomic_number FROM elements WHERE symbol='$SYMBOL')")
      MELTS=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=(SELECT atomic_number FROM elements WHERE symbol='$SYMBOL')")
      BOILS=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=(SELECT atomic_number FROM elements WHERE symbol='$SYMBOL')")
      echo "The element with symbol $SYMBOL is $NAME. It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTS°C and a boiling point of $BOILS°C."
    else
      echo "I could not find that element in the database."
    fi

  # If the provided input is a name (full word, case insensitive)
  elif [[ $PROVIDED =~ ^[a-zA-Z]+$ ]]; then
    CAPITALIZED_PROVIDED="${PROVIDED^}"  # Capitalize first letter of name
    NAME=$($PSQL "SELECT name FROM elements WHERE name='$CAPITALIZED_PROVIDED'")
    if [[ -n $NAME ]]; then
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$CAPITALIZED_PROVIDED'")
      TYPE=$($PSQL "SELECT types.type FROM elements FULL JOIN properties ON properties.atomic_number = elements.atomic_number JOIN types ON properties.type_id = types.type_id WHERE name='$CAPITALIZED_PROVIDED'")
      MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=(SELECT atomic_number FROM elements WHERE name='$CAPITALIZED_PROVIDED')")
      MELTS=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=(SELECT atomic_number FROM elements WHERE name='$CAPITALIZED_PROVIDED')")
      BOILS=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=(SELECT atomic_number FROM elements WHERE name='$CAPITALIZED_PROVIDED')")
      echo "The element $NAME ($SYMBOL) is a $TYPE, with a mass of $MASS amu. It has a melting point of $MELTS°C and a boiling point of $BOILS°C."
    else
      echo "I could not find that element in the database."
    fi

  else
    echo "Invalid input. Please provide a valid atomic number, symbol, or element name."
  fi
}

GET_INFO
