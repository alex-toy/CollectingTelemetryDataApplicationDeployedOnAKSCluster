# Variables
$Global:resourceGroup="alexeirg"
$Global:location="francecentral"

az group create --name $resourceGroup --location $location

."commands\AI_create.ps1"

bash ./commands/setup-script.sh $resourceGroup $location

# ."commands\K8sCluster_create.ps1"




