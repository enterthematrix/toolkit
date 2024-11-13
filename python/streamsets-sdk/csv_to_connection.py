import configparser
import time
import warnings
# Import the ControlHub class from the SDK.
from streamsets.sdk import ControlHub

start_time = time.time()
config = configparser.ConfigParser()
config.optionxform = lambda option: option

CREDENTIALS_PROPERTY_PATH = "../../private/credentials.properties"
config.read(CREDENTIALS_PROPERTY_PATH)
CRED_ID = config.get("SECURITY", "CRED_ID")
CRED_TOKEN = config.get("SECURITY", "CRED_TOKEN")

warnings.simplefilter("ignore")
# Connect to the StreamSets DataOps Platform.
sch = ControlHub(credential_id=CRED_ID, token=CRED_TOKEN)
# Instantiate the ConnectionBuilder instance
connection_builder = sch.get_connection_builder()
# Retrieve the Data Collector engine to be used as the authoring engine
engine = sch.engines.get(engine_url='http://sdc.cluster:18512')

# Available connection types: **
#
# STREAMSETS_AWS_EMR_CLUSTER
# STREAMSETS_MYSQL
# STREAMSETS_SNOWFLAKE
# STREAMSETS_COAP_CLIENT
# STREAMSETS_OPC_UA_CLIENT
# STREAMSETS_GOOGLE_PUB_SUB
# STREAMSETS_MQTT
# STREAMSETS_POSTGRES
# STREAMSETS_GOOGLE_CLOUD_STORAGE
# STREAMSETS_AWS_REDSHIFT
# STREAMSETS_GOOGLE_BIG_QUERY
# STREAMSETS_ORACLE
# STREAMSETS_AWS_S3
# STREAMSETS_REMOTE_FILE
# STREAMSETS_SQLSERVER
# STREAMSETS_AWS_SQS
# STREAMSETS_SNOWPIPE
# STREAMSETS_JDBC

# CONNECTION_TYPE = ['STREAMSETS_AWS_EMR_CLUSTER', 'STREAMSETS_MYSQL', 'STREAMSETS_SNOWFLAKE', 'STREAMSETS_COAP_CLIENT',
#                    'STREAMSETS_OPC_UA_CLIENT', 'STREAMSETS_GOOGLE_PUB_SUB', 'STREAMSETS_MQTT', 'STREAMSETS_POSTGRES',
#                    'STREAMSETS_GOOGLE_CLOUD_STORAGE', 'STREAMSETS_AWS_REDSHIFT', 'STREAMSETS_GOOGLE_BIG_QUERY',
#                    'STREAMSETS_ORACLE', 'STREAMSETS_AWS_S3', 'STREAMSETS_REMOTE_FILE', 'STREAMSETS_SQLSERVER',
#                    'STREAMSETS_AWS_SQS', 'STREAMSETS_SNOWPIPE', 'STREAMSETS_JDBC']

# Build the Connection instance by passing a few key parameters into the build method
connection = connection_builder.build(title='sanju_s3_sdk',
                                      connection_type='STREAMSETS_AWS_S3',
                                      authoring_data_collector=engine,
                                      tags=['sdk_example', 's3_connection'])

# Specify the credential mode as 'WITH_CREDENTIALS' to use a key pair, or 'WITH_IAM_ROLES' to use an instance profile
connection.connection_definition.configuration['awsConfig.credentialMode'] = 'WITH_CREDENTIALS'
connection.connection_definition.configuration['awsConfig.awsAccessKeyId'] = 12345
connection.connection_definition.configuration['awsConfig.awsSecretAccessKey'] = 67890
sch.add_connection(connection)

# Retrieve a connection to update via specific name
connection = sch.connections.get(name='sanju_s3_sdk')
# Update properties of the connection (in this case the name of the connection as well as the Access Key/Secret Access Key values for accessing S3)
connection.connection_definition.configuration['awsConfig.awsAccessKeyId'] = 234
connection.connection_definition.configuration['awsConfig.awsSecretAccessKey'] = 567
connection.name = 'sanju_s3_sdk_prod'
# Publish the updated connection to the Platform
sch.update_connection(connection)

# Run the verification, and then check the results
verification_result = sch.verify_connection(connection)

# Get the connection
connection = sch.connections.get(name='sanju_s3_sdk_prod')
# sch.delete_connection(connection)
print("Time for completion: ", (time.time() - start_time), " secs")
