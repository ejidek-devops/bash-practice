#!/bin/bash

#============================
# Name: Adekunle
# date: 24th Nov, 2025
# about: use this script to track resouces
#===========================

# AWS s3
# AWS Ec2
# AWS IAM
# AWS 

set -euo pipefail

REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || echo us-east-1)}"
PROFILE_FLAG=""
if [ -n "${AWS_PROFILE:-}" ]; then
  PROFILE_FLAG="--profile ${AWS_PROFILE}"
fi

check_prereqs() {
  command -v aws >/dev/null 2>&1 || { echo "aws CLI not found. Install and configure it."; exit 1; }
  command -v jq >/dev/null 2>&1 || { echo "jq not found. Install jq."; exit 1; }
  if ! aws $PROFILE_FLAG sts get-caller-identity >/dev/null 2>&1; then
    echo "AWS credentials not valid or not configured for profile ${AWS_PROFILE:-default}."
    exit 1
  fi
}

list_s3() {
  echo "==== S3 Buckets ===="
  aws $PROFILE_FLAG s3api list-buckets --query "Buckets[].Name" --output json | jq -r '.[]' || echo "No buckets or permission denied."
  COUNT=$(aws $PROFILE_FLAG s3api list-buckets --query "length(Buckets)" --output text 2>/dev/null || echo 0)
  echo "Total buckets: ${COUNT}"
  echo
}

list_ec2() {
  echo "==== EC2 Instances (by region) ===="
  REGIONS=$(aws $PROFILE_FLAG ec2 describe-regions --query "Regions[].RegionName" --output text)
  for r in $REGIONS; do
    INSTANCES=$(aws $PROFILE_FLAG ec2 describe-instances --region "$r" \
      --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,Placement.AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' --output json)
    if [ "$(echo "$INSTANCES" | jq 'length')" -gt 0 ]; then
      echo "Region: $r"
      echo "$INSTANCES" | jq -r '.[] | @tsv' | awk -F'\t' '{printf "  %-20s %-10s %-12s %-16s %s\n",$1,$2,$3,$4,$5}'
      echo
    fi
  done
  TOTAL=$(aws $PROFILE_FLAG ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output json | jq 'length')
  echo "Total EC2 instances: ${TOTAL}"
  echo
}

list_iam() {
  echo "==== IAM Users ===="
  aws $PROFILE_FLAG iam list-users --query 'Users[].{UserName:UserName,CreateDate:CreateDate}' --output json | jq -r '.[] | "\(.UserName)\t\(.CreateDate)"' | column -t -s $'\t' || echo "No IAM users or permission denied."
  COUNT=$(aws $PROFILE_FLAG iam list-users --query 'Users | length(@)' --output text 2>/dev/null || echo 0)
  echo "Total IAM users: ${COUNT}"
  echo
}

list_rds() {
  echo "==== RDS Instances (by region) ===="
  REGIONS=$(aws $PROFILE_FLAG ec2 describe-regions --query "Regions[].RegionName" --output text)
  for r in $REGIONS; do
    INST=$(aws $PROFILE_FLAG rds describe-db-instances --region "$r" --query 'DBInstances[].{Id:DBInstanceIdentifier,Engine:Engine,Class:DBInstanceClass,Status:DBInstanceStatus}' --output json 2>/dev/null || echo "[]")
    if [ "$(echo "$INST" | jq 'length')" -gt 0 ]; then
      echo "Region: $r"
      echo "$INST" | jq -r '.[] | "\(.Id)\t\(.Engine)\t\(.Class)\t\(.Status)"' | column -t -s $'\t'
      echo
    fi
  done
  TOTAL=$(aws $PROFILE_FLAG rds describe-db-instances --region "$REGION" --query 'DBInstances | length(@)' --output text 2>/dev/null || echo 0)
  echo "RDS instaces in ${REGION}: ${TOTAL}"
  echo
}

summary() {
  echo "==== Summary ===="
  BUCKETS=$(aws $PROFILE_FLAG s3api list-buckets --query "length(Buckets)" --output text 2>/dev/null || echo 0)
  INSTANCES=$(aws $PROFILE_FLAG ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output json 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
  USERS=$(aws $PROFILE_FLAG iam list-users --query 'Users | length(@)' --output text 2>/dev/null || echo 0)
  echo "Buckets: ${BUCKETS}"
  echo "EC2 instances: ${INSTANCES}"
  echo "IAM users: ${USERS}"
  echo
}

main() {
  check_prereqs
  cmd="${1:-all}"
  case "$cmd" in
   all)
      list_s3
      list_ec2
      list_iam
      list_rds
      summary
      ;;
    s3) list_s3 ;;
    ec2) list_ec2 ;;
    iam) list_iam ;;
    rds) list_rds ;;
    summary) summary ;;
    *) echo "Usage: $0 [all|s3|ec2|iam|rds|summary]"; exit 1 ;;
  esac
}

main "$@"
# ...existing code...