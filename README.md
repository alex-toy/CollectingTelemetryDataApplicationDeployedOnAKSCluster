Collecting Telemetry Data for an application deployed on AKS cluster
=

## Prerequisite
You should have an Application Insights instance already created in your account
You should have an application already deployed on the AKS cluster

1. Copy the Instrumentation Key of your Application Insights instance
    - If you aren't already, log in to Azure Portal.
    - Navigate to your Application Insights instance.
    - Copy the instrumentation key.

2. Edit the Dockerfile [Only for deployment to AKS]
Add the following dependencies to the azure-voting-app-redis/azure-vote/Dockerfile included in the starter code used in the last exercise.
The first line below would already be there
RUN pip install redis
RUN pip install opencensus
RUN pip install opencensus-ext-azure
RUN pip install opencensus-ext-flask
RUN pip install opencensus-ext-logging
RUN pip install flask
Step 3 - Edit the main.py
Note that the working main.py file is attached at the bottom of this page as well. But, we encourage you to go through each code block below and add it to your main.py file.

Open the azure-voting-app-redis/azure-vote/azure-vote/main.py file, and import the following AppInsight libraries:
import logging
from datetime import datetime
# App Insights
# TODO: Import required libraries for App Insights
from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.ext.azure.log_exporter import AzureEventHandler
from opencensus.ext.azure import metrics_exporter
from opencensus.stats import aggregation as aggregation_module
from opencensus.stats import measure as measure_module
from opencensus.stats import stats as stats_module
from opencensus.stats import view as view_module
from opencensus.tags import tag_map as tag_map_module
from opencensus.trace import config_integration
from opencensus.ext.azure.trace_exporter import AzureExporter
from opencensus.trace.samplers import ProbabilitySampler
from opencensus.trace.tracer import Tracer
from opencensus.ext.flask.flask_middleware import FlaskMiddleware
# For metrics
stats = stats_module.stats
view_manager = stats.view_manager
Add Logger for custom Events:
config_integration.trace_integrations(['logging'])
config_integration.trace_integrations(['requests'])
# Standard Logging
logger = logging.getLogger(__name__)
handler = AzureLogHandler(connection_string='InstrumentationKey=[your-guid]')
handler.setFormatter(logging.Formatter('%(traceId)s %(spanId)s %(message)s'))
logger.addHandler(handler)
# Logging custom Events 
logger.addHandler(AzureEventHandler(connection_string='InstrumentationKey=[your-guid]'))
# Set the logging level
logger.setLevel(logging.INFO)
Add Metrics
# Metrics
exporter = metrics_exporter.new_metrics_exporter(
enable_standard_metrics=True,
connection_string='InstrumentationKey=[your-guid]')
view_manager.register_exporter(exporter)
Add Tracer
# Tracing
tracer = Tracer(
 exporter=AzureExporter(
     connection_string='InstrumentationKey=[your-guid]'),
 sampler=ProbabilitySampler(1.0),
)
app = Flask(__name__)
Add Requests

# Requests
middleware = FlaskMiddleware(
 app,
 exporter=AzureExporter(connection_string="InstrumentationKey=[your-guid]"),
 sampler=ProbabilitySampler(rate=1.0)
)
In the code snippet above, replace [your-guid] with the Instrumentation Key copied in the step above. For example, after replacement, the connection string would look like:

connection_string='InstrumentationKey=cc4cd863-cad1-469e-ba7e-87ec2c4ed5d0'),
Also, ensure the Redis connection according to the deployment. For localhost / single-host deployment (VMSS), the configuration will be:

# Redis Connection to a local server running on the same machine where the current Flask app is running. 
r = redis.Redis()
Whereas, for multi-container (AKS) deployment, the configuration will be:

redis_server = os.environ['REDIS']
# Redis Connection to another container
try:
 if "REDIS_PWD" in os.environ:
     r = redis.StrictRedis(host=redis_server,
                     port=6379,
                     password=os.environ['REDIS_PWD'])
 else:
     r = redis.Redis(redis_server)
 r.ping()
except redis.ConnectionError:
 exit('Failed to connect to Redis, terminating.')
Use tracer.span() to capture an event. Also, use logger.info() to send custom events to the Application Insights instance. For this purpose, you need to add custom properties to your log messages in the extra keyword argument (see below). For example:

@app.route('/', methods=['GET', 'POST'])
def index():

 if request.method == 'GET':

     # Get current values
     vote1 = r.get(button1).decode('utf-8')
     # TODO: use tracer object to trace cat vote
     with tracer.span(name="Cats Vote") as span:
         print("Cats Vote")

     vote2 = r.get(button2).decode('utf-8')
     # TODO: use tracer object to trace dog vote
     with tracer.span(name="Dogs Vote") as span:
         print("Dogs Vote")

     # Return index with values
     return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)

 elif request.method == 'POST':

     if request.form['vote'] == 'reset':

         # Empty table and return results
         r.set(button1,0)
         r.set(button2,0)
         vote1 = r.get(button1).decode('utf-8')
         properties = {'custom_dimensions': {'Cats Vote': vote1}}
         # TODO: use logger object to log cat vote
         logger.info('Cats Vote', extra=properties)

         vote2 = r.get(button2).decode('utf-8')
         properties = {'custom_dimensions': {'Dogs Vote': vote2}}
         # TODO: use logger object to log dog vote
         logger.info('Dogs Vote', extra=properties)

         return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)

     else:

         # Insert vote result into DB
         vote = request.form['vote']
         r.incr(vote,1)

         # Get current values
         vote1 = r.get(button1).decode('utf-8')
         properties = {'custom_dimensions': {'Cats Vote': vote1}}
         # TODO: use logger object to log cat vote
         logger.info('Cats Vote', extra=properties)

         vote2 = r.get(button2).decode('utf-8')
         properties = {'custom_dimensions': {'Dogs Vote': vote2}}
         # TODO: use logger object to log dog vote
         logger.info('Dogs Vote', extra=properties)            

         # Return results
         return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)
Note the following regarding using tracer:

The supported versions of Python are v2.7 and v3.4-v3.7.
Ensure the sampler=ProbabilitySampler(1.0) so it collects 100% of the data. The range of acceptible values are between (0.0-1.0).
With tracer.span(name='myTrace'), a telemetry item will be sent for the span "myTrace"
These events will be displayed in the Application Insights instance in Azure. Also, you can change the values in the azure-vote/azure-vote/config_file.cfg file to see if the changes persist after re-deployment.

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