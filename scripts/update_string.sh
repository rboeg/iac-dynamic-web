#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 \"New message string\" [aws_profile]"
  exit 1
fi

NEW_MESSAGE="$1"
AWS_PROFILE="${2:-}"  # Use second argument if provided, otherwise empty
PARAM_NAME="/tf_dyn_web/message"

# Build AWS CLI profile option
PROFILE_OPTION=""
if [ -n "$AWS_PROFILE" ]; then
  PROFILE_OPTION="--profile $AWS_PROFILE"
fi

# Update the SSM parameter
aws ssm put-parameter \
  $PROFILE_OPTION \
  --name "$PARAM_NAME" \
  --value "$NEW_MESSAGE" \
  --type String \
  --overwrite

echo "Updated $PARAM_NAME to: $NEW_MESSAGE using profile: ${AWS_PROFILE:-default}"
