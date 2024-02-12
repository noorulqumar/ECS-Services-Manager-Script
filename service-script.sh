#!/bin/bash

# Define your ECS cluster name
CLUSTER_NAME="davis-index-development"

DAYS_TO_WAIT=6

# Get a list of services in the cluster
SERVICES=$(aws ecs list-services --cluster $CLUSTER_NAME --output text --query "serviceArns[*]")

# Calculate the date 6 days ago
DATE_6_DAYS_AGO=$(date -d "$DAYS_TO_WAIT days ago" "+%Y-%m-%dT%H:%M:%S")

# Loop through each service
for SERVICE in $SERVICES; do
    # Get the service name
    SERVICE_NAME=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE --output text --query "services[0].serviceName")

    # Skip services with names "Activepieces" or "baserow"
    if [[ "$SERVICE_NAME" == "Activepieces" || "$SERVICE_NAME" == "baserow" ]]; then
        echo "Skipping service $SERVICE_NAME"
        continue
    fi

    # Get a list of tasks for the service
    TASKS=$(aws ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE --output text --query "taskArns[*]")

    # Loop through each task
    for TASK in $TASKS; do
        # Get the task creation time in epoch format
        TASK_CREATED_AT_EPOCH=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK --output text --query "tasks[0].createdAt")

        # Convert epoch time to ISO 8601 format
        TASK_CREATED_AT=$(date -d @$TASK_CREATED_AT_EPOCH "+%Y-%m-%dT%H:%M:%S")

        # Compare the task creation time with the date 6 days ago
        if [[ "$TASK_CREATED_AT" < "$DATE_6_DAYS_AGO" ]]; then
            echo "Setting desired task count to 0 for task $TASK in service $SERVICE"
            aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE --desired-count 0 > /dev/null
        else
            echo "Not Setting desired task count to 0 for task $TASK in service $SERVICE"
        fi
    done
done

echo "All eligible services in the cluster have been set to 0 desired tasks."
