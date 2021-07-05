import json
import boto3

#copy the endpoint name
ENDPOINT_NAME = 'sagemaker-scikit-learn-2021-05-26-15-13-17-776'
CONTENT_TYPE = 'text/csv'

runtime = boto3.client('sagemaker-runtime')


def rest_to_sagemaker_handler(event, context):

    #### JUST TO TEST IT
    response = {
        "statusCode": 200,
        "headers": {
            "my_header": "my_value"
        },
        "body": json.dumps({"ciao": "bello"}, separators=(',', ':')),
        "isBase64Encoded": False
    }
    return response
    #### END TEST
    

    for value in event.values():
        try:
            float(value)
        except:
            return value + ' is not a valid float'
    
    payload = ""
    for value in event.values():
        payload += value + ","
    
    payload = payload[:-1]
    
    # Call the endpoint
    response = runtime.invoke_endpoint(
        EndpointName=ENDPOINT_NAME,
        ContentType=CONTENT_TYPE,
        Body=payload
    )
    
    resp = response['Body'].read().decode()
    
    # Return the prediction
    #return json.dumps({ 'prediction' : resp }, indent=2)
    return {
        'statusCode': 200,
        'body': {
            "prediction" : resp
        }
    }
