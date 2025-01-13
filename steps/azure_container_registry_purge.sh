#!/bin/bash

# define functions first - before usage
# echo to >&2 for stderr, for logs
# echo to stdout for function output

set_subscription() {
  local subscription_id=$1
  echo "setting subscription to ${subscription_id}"
  az account set --subscription "$subscription_id"
  if [ $? -ne 0 ]; then
      echo "Failed to set subscription: $subscription_id" >&2
      exit 1
  fi
}

app_services_in_sub() {
  echo "fetching app services"
  app_services=$(az webapp list --query "[].{name: name, resourceGroup: resourceGroup}" -o tsv)
  if [ $? -ne 0 ]; then
      echo "Failed to list web apps for subscription" >&2
      exit 1
  fi
  echo "app services:"
  echo "$app_services"
}

image_tag_name() {
  local name=$1
  local resource_group=$2
  local slot=$3

  echo "fetch tag name for ${name} ${resource_group} ${slot}"

  # get config
  local container_image_name=$(az webapp config container show --name "$name" --resource-group "$resourceGroup" --slot "$slot")
  if [ $? -ne 0 ]; then
      echo "Failed to get container image for app service: $name in resource group: $resourceGroup" >&2
      exit 1
  fi

  # find the image name
  container_image=$(echo $container_image_name | jq -r '.[] | select(.name == "DOCKER_CUSTOM_IMAGE_NAME").value' | awk -F'|' '{print $2}')
  echo "tag name for ${name} ${resource_group} ${slot} is ${container_image}"
  echo "$container_image"
}

images_in_sub() {
  local in_use_images=()
  local subscription_id=$1
  local app_services=$(app_services_in_sub "$subscription_id")
  if [ $? -ne 0 ]; then
    exit 1
  fi

  echo "fetch images for sub ${subscription_id}"

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

if [ -z "${ACR_NAME}" ]; then
    acr_name="pinscrsharedtoolinguks"
else
    acr_name=${ACR_NAME}
fi

if [ -z "${APP_SERVICE_SUBSCRIPTIONS}" ]; then
    app_service_subscription_ids=$(echo '["962e477c-0f3b-4372-97fc-a198a58e259e","76cf28c6-6fda-42f1-bcd9-6d7dbed704ef","dbfbfbbf-eb6f-457b-9c0c-fe3a071975bc","d1d6c393-2fe3-40af-ac27-f5b6bad36735"]' | jq -r '.[]')
else
    app_service_subscription_ids=$(echo "$APP_SERVICE_SUBSCRIPTION_IDS" | jq -r '.[]')
fi

repositories=$(echo "$REPOSITORIES" | jq -r '.[]')

echo "acr sub id:"
echo "$acr_subscription_id"
echo "acr name:"
echo "$acr_name"
echo "Subs:"
echo "${app_service_subscription_ids[@]}"
echo "Repositories:"
echo "${repositories[@]}"

# run the script

# get a list of images currently in use
in_use_images=()
while read -r subscription_id; do
  set_subscription "$subscription_id" || exit 1
  tags=$(images_in_sub) || exit 1
  in_use_images+=( $tags )
done <<< "$app_service_subscription_ids" # pass sub ids (one per line) to read

echo "Images:"
echo "${in_use_images[@]}"

# login to acr
echo "switching to acr subscription"
set_subscription "$acr_subscription_id" || exit 1
echo "logging in to acr"
az acr login --name "${acr_name}" || exit 1

for repository in "${repositories[@]}"; do
  all_tags=$(az acr repository show-tags --name "${acr_name}" --repository "$repository" --output tsv)
  IFS=$'\n' read -r -d '' -a all_tags_array <<< "$all_tags"

  images_to_purge=()
  for tag in "${all_tags_array[@]}"; do
    if ! [[ " ${in_use_images[@]} " =~ " ${acr_name}.azurecr.io/$repository:$tag " ]]; then
      images_to_purge+=("$repository:$tag")
    fi
  done

  echo "$repository include: ${images_to_purge[@]}"

  for tag in "${images_to_purge[@]}"; do
    echo "delete --image $tag"
    # az acr repository delete --name "${acr_name}" --image "$tag" --yes || exit 1
  done
done

echo "ACR cleanup completed"