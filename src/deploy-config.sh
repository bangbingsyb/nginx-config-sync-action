#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

subscriptionId=$1
resourceGroupName=$2
nginxDeploymentName=$3
configDirInRepo=$4
rootConfigFilePath=$5

# Read and encode the NGINX configuration file content.
if [ -d "$configDirInRepo" ]
then
    echo "The NGINX configuration directory was found."
else 
    echo "The NGINX configuration directory $configDirInRepo does not exist."
    exit 2
fi

configTarball="nginx-conf.tar.gz" 
tar -cvzf "$configTarball" -C "$configDirInRepo" --xform s:'./':: .
tar -tf "$configTarball"

encodedConfigTarball=$(base64 "$configTarball")
echo "Base64 encoded NGINX configuration tarball"
echo "$encodedConfigTarball"
echo ""

# Deploy the configuration to the NGINX instance on Azure using an ARM template.
uuid="$(cat /proc/sys/kernel/random/uuid)"
templateFile="template-$uuid.json"
templateDeploymentName="${nginxDeploymentName:0:20}-$uuid"

wget -O "$templateFile" https://raw.githubusercontent.com/bangbingsyb/nginx-config-sync-action/main/src/nginx-for-azure-configuration-template.json
echo "Downloaded the ARM template for deploying NGINX configuration"
cat "$templateFile"
echo ""

echo "Deploying NGINX configuration"
echo "Subscription: $subscriptionId"
echo "Resource group: $resourceGroupName"
echo "NGINX deployment name: $nginxDeploymentName"
echo "Template deployment name: $templateDeploymentName"
echo ""

az account set -s "$subscriptionId" --verbose
az deployment group create --name "$templateDeploymentName" --resource-group "$resourceGroupName" --template-file "$templateFile" --parameters nginxDeploymentName="$nginxDeploymentName" rootFile="$rootConfigFilePath" tarball="$encodedConfigTarball" --verbose
