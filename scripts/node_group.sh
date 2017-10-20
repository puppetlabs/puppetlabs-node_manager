#!/bin/bash
[[ -f ~/.node_managerrc ]] && source ~/.node_managerrc

# Help text
HELP=`cat <<-EOF
Usage: $0 [options] [UID]\n
\n
-n| --name           \t\t The name of the node_group.\n
\t                   \t\t *Required to create a new group.\n\n
-x| --ensure         \t\t Set to [present|absent] for existence.\n
\t                   \t\t Default: present\n\n
-d| --description      \t Description of group.\n\n
-e| --environment      \t Puppet environment for group.\n
\t                   \t\t Default: production\n\n
-o| --override         \t Set to [true|false] for environment group.\n
\t                   \t\t Default: false\n\n
-p| --parent         \t\t Parent group UID.\n
\t                   \t\t Default: 00000000-0000-4000-8000-000000000000\n\n
-c| --classes        \t\t Hash of classes and parameters.\n
\t                   \t\t Example: '{ "vim": {} }'\n\n
-r| --rule           \t\t Array of rules for matching.\n
\t                   \t\t Example: '["or", ["=", "name", "node.whatsaranjit.com"]]'\n\n
-v| --variables        \t Variables to set in the group.\n
\t                   \t\t Example: '{ "foo": "bar" }'\n\n
-a| --config_data      \t Configuration data for the group.\n
\t                   \t\t Example: '{ "vim": { "vim_package": "vim-common" } }'\n\n
-h| --help           \t\t Display this help message.\n
EOF`

# Defaults
MASTER="${MASTER:-`hostname -f`}"
PORT="${PORT:-4433}"

# File to catch response headers
DUMP=$(mktemp)
CURL="/usr/bin/curl -s -k -D ${DUMP}"
CLASSIFIER_URL="https://${MASTER}:${PORT}/classifier-api/v1/groups"

# Get all groups
if [[ $# -eq 0 ]]; then
  $CURL -X GET \
  -H "Content-Type: application/json" \
  -H "X-Authentication: ${TOKEN}" \
  $CLASSIFIER_URL \
  | python -m json.tool 2> /dev/null \
  || (>&2 echo "Unable to hit API!"; exit 1)
# Get single group
elif [[ $# -eq 1 ]]; then
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e $HELP
    exit 0
  fi
  $CURL -X GET \
  -H "Content-Type: application/json" \
  -H "X-Authentication: ${TOKEN}" \
  "${CLASSIFIER_URL}/${1}" \
  | python -m json.tool 2> /dev/null \
  || (>&2 echo "Unable to hit API!"; exit 1)
# Create/update groups
else
  DATA='{'
  while [[ $# -gt 1 ]]; do
    key="$1"

    case $key in
      -h|--help)
        echo -e $HELP
        exit 0
      shift
      ;;
      -x|--ensure)
      ENSURE="$2"
      shift
      ;;
      -n|--name)
      NAME="$2"
      DATA="${DATA} \"name\": \"${NAME}\","
      shift
      ;;
      -d|--description)
      DESCRIPTION="$2"
      DATA="${DATA} \"description\": \"${DESCRIPTION}\","
      shift
      ;;
      -e|--environment)
      ENVIRONMENT="$2"
      DATA="${DATA} \"environment\": \"${ENVIRONMENT}\","
      shift
      ;;
      -o|--override)
      OVERRIDE="$2"
      DATA="${DATA} \"environment_trumps\": ${OVERRIDE},"
      shift
      ;;
      -p|--parent)
      PARENT="$2"
      DATA="${DATA} \"parent\": \"${PARENT}\","
      shift
      ;;
      -c|--classes)
      CLASSES="$2"
      DATA="${DATA} \"classes\": ${CLASSES},"
      shift
      ;;
      -r|--rule)
      RULE="$2"
      DATA="${DATA} \"rule\": $RULE,"
      shift
      ;;
      -v|--variables)
      VARIABLES="$2"
      DATA="${DATA} \"variables\": $VARIABLES,"
      shift
      ;;
      -a|--config_data)
      CONFIG_DATA="$2"
      DATA="${DATA} \"config_data\": ${CONFIG_DATA},"
      shift
      ;;
      *)
        (>&2 echo "Invalid options supplied!"); exit 1
      ;;
    esac
    shift
  done
  # Set defaults if they weren't given
  if [[ -z $PARENT ]]; then
    DATA="${DATA} \"parent\": \"00000000-0000-4000-8000-000000000000\","
  fi
  if [[ -z $CLASSES ]]; then
    DATA="${DATA} \"classes\": {},"
  fi
  # Remove trailing comma
  DATA=`sed 's/,$//' <<< $DATA`
  DATA="${DATA} }"
  # Last arg, if given, is the group ID
  ID=$1
  if [[ ! -z $ID ]]; then
    URL="${CLASSIFIER_URL}/${ID}"
  else
    URL=$CLASSIFIER_URL
  fi
  # Do cURL with JSON data
  if [[ "$ENSURE" == "absent" ]]; then
    $CURL -X DELETE \
    -H "Content-Type: application/json" \
    -H "X-Authentication: ${TOKEN}" \
    $URL \
    || (>&2 echo "Unable to hit API!"; exit 1)
  else
    $CURL -X POST \
    -H "Content-Type: application/json" \
    -H "X-Authentication: ${TOKEN}" \
    --data "${DATA}" \
    $URL \
    | python -m json.tool 2> /dev/null || (
      NEWID=`grep 'Location' $DUMP | cut -d '/' -f5`
      if [[ ! -z $NEWID ]]; then
        echo "New group ID: ${NEWID}"
      else
        (>&2 echo "Unable to hit API!"); exit 1
      fi
    )
  fi
fi

CODE=`grep 'HTTP/' $DUMP | cut -d ' ' -f2`

# All good
if [[ "$CODE" -eq '200' ]]; then
  exit 0
# Successful creation
elif [[ "$CODE" -eq '201' ]]; then
  exit 2
# Successful delete
elif [[ "$CODE" -eq '204' ]]; then
  echo "${ID} removed"
  exit 2
# Successful creation
elif [[ "$CODE" -eq '303' ]]; then
  exit 2
# Bad schema
elif [[ "$CODE" -eq '400' ]]; then
  exit 1
# ID not found
elif [[ "$CODE" -eq '404' ]]; then
  exit 1
# Violating uniqueness
elif [[ "$CODE" -eq '422' ]]; then
  exit 4
# Huh?
else
  exit 1
fi
