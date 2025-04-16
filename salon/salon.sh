#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ WELCOME TO BUTTI SALON ~~\n"

# List services
SERVICES() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "\nAVAILABLE SERVICES:\n"
  $PSQL "SELECT service_id, name FROM services" | while read SERVICE_ID BAR NAME; do
    if [[ -n $SERVICE_ID ]]; then
      echo "$SERVICE_ID) $NAME"
    fi
  done
  USER_SELECTION
}

# Handle user selection
USER_SELECTION() {
  echo -e "\nWhich service would you like to choose?"
  read SERVICE_ID_SELECTED

  # Validate service ID
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || (( SERVICE_ID_SELECTED < 1 || SERVICE_ID_SELECTED > 10 )); then
    SERVICES "You picked an invalid service ID. Select from the list below."
  else
    echo -e "\nYou picked service ID: $SERVICE_ID_SELECTED"

    # Ask for phone number
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)
    if [[ -z $CUSTOMER_ID ]]; then
      echo -e "\nEnter your full name:"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)
    fi

    # Ask for appointment time
    echo -e "\nEnter appointment time:"
    read SERVICE_TIME

    # Insert appointment
    $PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)"

    # Get service and customer name for confirmation
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | xargs)
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID" | xargs)

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    echo -e "\n~~ Thank you for booking with BUTTI SALON ~~"
    exit 0
  fi
}

SERVICES
