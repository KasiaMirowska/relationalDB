#!/bin/bash


PSQL="psql --username=freecodecamp --dbname=<database_name> -t --no-align -c"


GET_INFO() {

  if [[ -z $1 ]]; then
    echo "Please provide an element as an argument."
    exit 1
  else
    echo -e "\nYou entered: $1"
    # Later: Do a lookup using atomic number, symbol, or name
  fi

}




GET_INFO "$1"