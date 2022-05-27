Collecting Telemetry Data for an application deployed on AKS cluster
=

## Prerequisite
You should have an Application Insights instance already created in your account
You should have an application already deployed on the AKS cluster

1. Copy the Instrumentation Key of your Application Insights instance
    - Navigate to your Application Insights instance.
    - Copy the instrumentation key.


Reference:

Set up Azure Monitor for your Python application
Tracking Flask applications
Using opencensus-ext-azure package - Scroll down to see example snippets. Although, some of them are already the same as the links above.
Step 4 - Redeploy the app to the VMSS
If your VMSS is still there, you can try deploying the application manually to at least one of the VMSS instances.
Remember that the Redis configuration is different in the case of VMSS versus AKS deployment. For VMSS, you will use r = redis.Redis(). Also, note that the driver function will vary slightly:
if __name__ == "__main__":
  # For running the application locally 
  # app.run() # local
  # For deployment to VMSS
  app.run(host='0.0.0.0', threaded=True, debug=True) # remote
Step 5 - Check the Application Insights instance
Go to the Azure Portal, and open your Application Insights instance. Click 'Events'. You will see your event. Make sure to use the right set of filters.

Application Insight | Usage | Events
Application Insight | Usage | Events

Application Insight | Usage | Events | View more insights
Application Insight | Usage | Events | View more insights

Step 6 - Redeploy the app to the AKS cluster
Run the following commands in your terminal:

# Stop and remove the local containers
docker-compose down
# Recreate containers because the frontend application has changed in the steps above 
docker-compose up -d --build --force-recreate
# Check the application running at http://localhost:8080/
# Tag the newly generated local image with the new tag, say "v2"
docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 myacr202106.azurecr.io/azure-vote-front:v2
# Login to the the ACR 
az acr login --name myacr202106
# Push the local image to the existing ACR 
docker push myacr202106.azurecr.io/azure-vote-front:v2
# Update the deployment image 
kubectl set image deployment azure-vote-front azure-vote-front=myacr202106.azurecr.io/azure-vote-front:v2
# Test the new deployment - use the external IP in your browser. 
kubectl get service azure-vote-front --watch
Run the flask app using the external IP in your browser and make the event trigger.

Reference: Tutorial: Update an application in Azure Kubernetes Service

Updated application running locally, and deployed on the AKS cluster
Updated application running locally, and deployed on the AKS cluster