#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {

  #RESET_INDEXES_RESULT=$($PSQL "alter sequence customers_pkey restart with 1")

  # print input if it exists
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # list of services
  echo "Services:"
  echo "$($PSQL "select * from services")" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED

  # get service name 
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  # if service doesn't exist
  if [[ -z $SERVICE_NAME ]]
  then
    # send to top
    MAIN_MENU "bad service_id"
  else
    # get service id
    SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")

    # ask for phone 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    # if phone not found
    if [[ -z $CUSTOMER_ID ]]
    then
      # ask for name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer data
      INSERT_NEW_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$CUSTOMER_NAME'")

    else
      # get customer name
      CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")
    fi

    # ask for service time
    echo -e "\nWhat time would you like to come in?"
    read SERVICE_TIME

    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
