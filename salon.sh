#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"
MAIN_MENU() {
  #if there is an argument passed to the function
  if [[ $1 ]]
  #then display that argument
  then
    echo -e "\n$1\n"
  fi
  #regardless of argument, continue with the rest of the main menu
  #get available services
  SERVICES=$($PSQL "SELECT * FROM services")
  #and display nicely formatted services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo ""
  #read input of service id desired
  read SERVICE_ID_SELECTED
  #if not a valid id
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    #then send to main menu with Service Not Found message
    MAIN_MENU "I'm sorry, that's not a valid entry. What service would you like?"
  #otherwise proceed to making appointment
  else
    SERVICE_NAME_SELECTED_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g')
    echo "Let's prepare to book your $SERVICE_NAME_SELECTED_FORMATTED appointment."
    #get customer phone number
    echo "What is your phone number?"
    read CUSTOMER_PHONE
    #look for customer name using phone
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if name not found
    if [[ -z $CUSTOMER_NAME ]]
    #then ask for name as input
    then
      echo "You're not in the system yet. What's your name?"
      read CUSTOMER_NAME
      #and insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    else
      echo "I see that you're already in our system."
    fi
    echo "For what time would you like to make your $SERVICE_NAME_SELECTED_FORMATTED appointment, $CUSTOMER_NAME?"
    read SERVICE_TIME
    #retrieve customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    #echo confirmation
    echo "I have put you down for a $SERVICE_NAME_SELECTED_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

#start with main menu
MAIN_MENU "\nWelcome to My Salon, what service would you like?\n"
