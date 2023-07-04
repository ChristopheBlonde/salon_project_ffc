#!/bin/bash

PSQL="psql -X -U freecodecamp -d salon -t -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
  echo -e "\n$1\n"
  else
  echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
do
echo "$SERVICE_ID) $SERVICE_NAME"
done
read SERVICE_ID_SELECTED
# get service mame
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
# if not found
if [[ -z $SERVICE_NAME ]]
then
# send to main menu
MAIN_MENU "I could not find that service. What would you like today?"
else
APPOINTMENTS $SERVICE_NAME $SERVICE_ID_SELECTED
fi
}

APPOINTMENTS(){
  # get customer id
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  echo "-->$CUSTOMER_PHONE"
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  echo "~~$CUSTOMER_NAME"
  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
  # get customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
  fi
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # get time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$2','$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
  then
  # send result message
  echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU