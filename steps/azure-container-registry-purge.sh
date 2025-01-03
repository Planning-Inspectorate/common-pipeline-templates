#!/bin/bash

# define functions first - before usage
# echo to >&2 for stderr, for logs
# echo to stdout for function output

app_services_in_sub() {
  local subscription_id=$1
  az account set --subscription "$subscription_id"
  if [ $? -ne 0 ]; then
      echo "Failed to set subscription: $subscription_id" >&2
      exit 1
  fi

  echo "fetching app services for ${subscription_id}" >&2
  app_services=$(az webapp list --query "[].{name: name, resourceGroup: resourceGroup}" -o tsv)
  if [ $? -ne 0 ]; then
      echo "Failed to list web apps for subscription: $subscription_id" >&2
      exit 1
  fi
  echo "app services for ${subscription_id}" >&2
  echo "${app_services}" >&2
  echo "" >&2
  echo "$app_services"
}

image_tag_name() {
  local name=$1
  local resource_group=$2
  local slot=$3

  echo "fetch tag name for ${name} ${resource_group} ${slot}" >&2

  # get config
  local container_image_name=$(az webapp config container show --name "$name" --resource-group "$resourceGroup" --slot "$slot")
  if [ $? -ne 0 ]; then
      echo "Failed to get container image for app service: $name in resource group: $resourceGroup" >&2
      exit 1
  fi

  # find the image name
  container_image=$(echo $container_image_name | jq -r '.[] | select(.name == "DOCKER_CUSTOM_IMAGE_NAME").value' | awk -F'|' '{print $2}')
  echo "tag name for ${name} ${resource_group} ${slot} is ${container_image}" >&2
  echo "$container_image"
}

images_in_sub() {
  local in_use_images=()
  local subscription_id=$1
  local app_services=$(app_services_in_sub "$subscription_id")
  if [ $? -ne 0 ]; then
    exit 1
  fi

  echo "fetch images for sub ${subscription_id}" >&2

  while IFS=$'\t' read -r name resource_group; do
    # default image tag
    image_tag=$(image_tag_name "$name" "$resource_group" "default")
    if [ $? -ne 0 ]; then
      exit 1
    fi
    if [ -n "$image_tag" ]; then
        in_use_images+=("$image_tag")
    fi
    # staging slot image tag
    image_tag=$(image_tag_name "$name" "$resource_group" "staging")
    if [ $? -ne 0 ]; then
      exit 1
    fi
    if [ -n "$image_tag" ]; then
        in_use_images+=("$image_tag")
    fi
  done <<< "$app_services" # pass contents of app_services to read
  echo "$in_use_images"
}


# pull variables from the environment
# ACR_SUBSCRIPTION_ID - subscription ID for the ACR
# APP_SERVICE_SUBSCRIPTION_IDS - JSON list of subscription IDs
# REPOSITORIES - JSON list of repository names

if [ -z "${ACR_SUBSCRIPTION_ID}" ]; then
    acr_subscription_id="edb1ff78-90da-4901-a497-7e79f966f8e2"
else
    acr_subscription_id=${ACR_SUBSCRIPTION_ID}
fi

if [ -z "${APP_SERVICE_SUBSCRIPTIONS}" ]; then
    app_service_subscription_ids=$(echo '["962e477c-0f3b-4372-97fc-a198a58e259e","76cf28c6-6fda-42f1-bcd9-6d7dbed704ef","dbfbfbbf-eb6f-457b-9c0c-fe3a071975bc","d1d6c393-2fe3-40af-ac27-f5b6bad36735"]' | jq -r '.[]')
else
    app_service_subscription_ids=$(echo "$APP_SERVICE_SUBSCRIPTION_IDS" | jq -r '.[]')
fi
repositories=$(echo "$REPOSITORIES" | jq -r '.[]')

# run the script

echo "ACR cleanup. Repositories:"
echo ""
echo "Repositories:"
echo "${repositories[@]}"
echo ""
echo "Subs:"
echo "${app_service_subscription_ids[@]}"
echo ""

in_use_images=()
while read -r subscription_id; do
  tags=$(images_in_sub "$subscription_id")
  if [ $? -ne 0 ]; then
    exit 1
  fi
  in_use_images+=( $tags )
done <<< "$app_service_subscription_ids" # pass sub ids (one per line) to read

echo "Images:"
echo "${in_use_images[@]}"

## TODO: read images, determine list to delete

echo "ACR cleanup completed"