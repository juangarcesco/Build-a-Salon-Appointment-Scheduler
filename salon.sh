#!/bin/bash

# Connect to PostgreSQL and display available services
PSQL="psql -U freecodecamp -d salon --no-align --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

# Function to display services
display_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nHere are the available services:\n"
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to prompt for service_id
get_service_id() {
  display_services
  echo -e "\nPlease select a service by entering the service_id:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # If service does not exist, re-prompt the user
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service_id. Please try again."
    get_service_id
  fi
}

get_service_id

# Get customer's phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
  # If customer doesn't exist, get their name
  echo -e "\nYou are not in our system. Please enter your name:"
  read CUSTOMER_NAME

  # Insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Get appointment time
echo -e "\nPlease enter the time for your appointment (e.g., 10:30):"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm appointment
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
