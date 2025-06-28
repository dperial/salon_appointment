#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Display list of service
DISPLAY_SERVICES() {
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  # echo -e "1) Cut\n2) Color\n3) Perm\n4) Style\n5) Trim\n6) Exit"
  DISPLAY_SERVICES
  echo -e "6) Exit"
  read SERVICE_ID_SELECTED
  case "$SERVICE_ID_SELECTED" in
    1|2|3|4|5) BOOK_SERVICE $SERVICE_ID_SELECTED ;;
    6) EXIT ;;
    *) MAIN_MENU "\nI could not find that service. What would you like today?" ;;
  esac
}

BOOK_SERVICE(){
  # get the service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  fi
  # get the phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # look for customer
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # check if the phone number exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # customer not found → ask for name + insert
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # Insert new customer into DB salon
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get the customer id after inserting into the customers table
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # ask for the appointment time
  echo -e "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert the new appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # display the appointment message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  MAIN_MENU
}
EXIT(){
  echo -e "\nThank you for visiting My Salon!"
}
MAIN_MENU
