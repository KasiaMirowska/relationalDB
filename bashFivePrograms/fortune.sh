#!/bin/bash
#Program to tell a persons fortune

echo -e "\n~~ Fortune Teller ~~\n"

RESPONSES=([0]="Yes" [1]="No"  [2]="Maybe" [3]="Outlook good" [4]="Don't count on it" [5]="Ask again later" )
N=$(( RANDOM % 6 ))

GET_FORTUNE()
{
  if [[ ! $1 ]]
  then
  echo Ask a yes or no question:
  else
  echo Try again. Make sure it ends with a question mark:
  fi
  read QUESTION
}

GET_FORTUNE

until [[ $QUESTION =~ \?$ ]]
do
  GET_FORTUNE again
done

echo -e "\n${RESPONSES[$N]}"