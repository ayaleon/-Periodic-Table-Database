#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

PSQL=(psql --username=freecodecamp --dbname=periodic_table -t --no-align -F '|' -v ON_ERROR_STOP=1)
QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p USING (atomic_number)
JOIN types t USING (type_id)
WHERE e.atomic_number::text = :'element' OR e.symbol = :'element' OR e.name = :'element';"

element_info=$("${PSQL[@]}" -v "element=$1" <<SQL
$QUERY
SQL
)

if [[ -z "$element_info" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r atomic_number name symbol element_type atomic_mass melting_point boiling_point <<< "$element_info"
printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$atomic_number" "$name" "$symbol" "$element_type" "$atomic_mass" "$name" "$melting_point" "$boiling_point"