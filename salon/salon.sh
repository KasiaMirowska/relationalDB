#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ WELCOME TO BUTTI SALON ~~\n"

#list services
SERVICES() {

  echo -e "\nAVAILABLE SERVICES:\n"
  $PSQL "SELECT service_id, name FROM services" | while read SERVICE_ID BAR NAME
  do
    if [[ -n $SERVICE_ID ]]; then
      echo "$SERVICE_ID) $NAME"
    fi
  done
}


#pick the service

#if not here , show the list again

#if is there then:
    #enter phone number
      # check if we have the record
      #if we don't fill in customer record
      #if we do
    #ask for service time
      #check if we have conflict 
      #if we do, go back to services with message
      #if we do not
    #enter appointment

SERVICES