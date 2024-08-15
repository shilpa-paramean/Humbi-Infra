import json
import boto3
import urllib.parse
import uuid
import os


def lambda_handler(event, context):
    state_machine_arn = os.environ['STATE_MACHINE_ARN']
    region = os.environ['REGION']
    env = os.environ['ENV']
   # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    input_date = bucket + "/" + key 

    
    output_data = bucket[:-3] + "-cz"
    if env == 'dev':
      client_name = bucket[4:-3]
    elif env == 'prod':
      client_name = bucket[5:-3]
    else:
      raise Exception("incorrect client")

    
    account_id = boto3.client('sts').get_caller_identity().get('Account')
    topic_arn = "arn:aws:sns:{}:{}:{}-{}-sns_zip_processing_notifier".format(region, account_id, env, client_name) 
    print ("input {}, output {}".format(input_date,output_data))
    client = boto3.client('stepfunctions')
    id = str(uuid.uuid4())
    data = {
        'archive': bucket + "-archive",
        'input':input_date,
        'output': output_data,
        'topic_arn': topic_arn
    }

    step_response = client.start_execution(stateMachineArn=state_machine_arn, name=id, input=json.dumps(data))

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

