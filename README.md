Migration using Azure Batch
=
In this project, we will gain experience in deploying applications and starting tasks in Azure Batch via the portal.

1. Create a new Azure Batch Account with a resource group
    - Resource Group Name: c3-lesson4-exercise-4
    - Batch Account Name: stockrecommenderxxx
2. Connect the Batch Account to an existing or new Storage
3. Upload the StockRecommender.zip file an Azure Batch application.
    - Note - Before uploading the zip, ensure the storage account is linked
    - Name: stockrecommender
    - Version: 1.0.0
4. Create an Azure Batch Pool
    - Pool ID: regular-vm
    - Image Type: Market Place
    - Publisher: canonical
    - Offer: ubuntuserver
    - SKU: the latest
    - VM Size: Standard A1
    - Target Dedicated Nodes: 1
    - Application Package: the recently added StockRecommender application
5. Create Batch Job
    - Name: stock-job
    - Pool: regular-vm created above
    - Create a task on the newly created job
    - Task ID/Name: stockrecommendertask1
    - /bin/sh -c $AZ_BATCH_APP_PACKAGE_stockrecommender_1_0_0/StockRecommender
6. Review the stdout.txt output of the task to view the recommended stock
    - Cleanup
    - Cleanup and delete resources
    - Be sure to clean up and delete resources to avoid recurring charges