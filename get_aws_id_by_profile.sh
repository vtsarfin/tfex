#!/bin/bash
PROFILE="test"
aws --profile $PROFILE sts get-caller-identity --query "Account" --output text
