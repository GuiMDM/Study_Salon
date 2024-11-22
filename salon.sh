#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display services
  SERVICES_LIST=$($PSQL "SELECT * FROM services")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1)  REGISTER_APPOINTMENT 1 ;;
    2)  REGISTER_APPOINTMENT 2 ;;
    3)  REGISTER_APPOINTMENT 3 ;;
    4)  REGISTER_APPOINTMENT 4 ;;
    5)  REGISTER_APPOINTMENT 5 ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

REGISTER_APPOINTMENT(){
  if [[ $1 ]]
  then
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$1")
  fi


  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # get phone number
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if customer not found
  if [[ -z $CUSTOMER_ID ]]
  then
    # ask name
    echo -e "\nI don't have a record for that phone number, what´s your name?"
    read CUSTOMER_NAME

    # insert customer
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  else
    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  fi

# get name service
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")

  # ask time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME

  # format text
  CUSTOMER_ID=$(echo $CUSTOMER_ID | sed -r 's/^ *| *$//g')
  SERVICE_ID=$(echo $SERVICE_ID | sed -r 's/^ *| *$//g')

  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU
