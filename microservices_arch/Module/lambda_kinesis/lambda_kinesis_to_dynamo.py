import json
import urllib3
import boto3
import uuid

dynamodb = boto3.client('dynamodb')

API_GATEWAY_ENDPOINT = '${api_url_complete}'
TABLE_NAME = 'davide-giorgio-prediction-wines-table'
CONTENT_TYPE = 'text/csv'

def kinesis_to_dynamo_handler(event, context):
    
    # Getting the prediction from the rest API
    # First we have to create the endpoint
    string = [f'{key}={value}' for key, value in event.items()]
    params = '&'.join(string)
    
    http = urllib3.PoolManager()
    URI = f'{API_GATEWAY_ENDPOINT}?{params}'
    r = http.request('GET', URI, preload_content=False)

    if r.status != 200:
        print('Error. Bad response from APi gateway')
        return
    
    r.release_conn()
    result = r.data.decode().strip()

    return result

    # Parse it from str to json
    prediction = json.loads(result)['body']['prediction']

    # adding a rando id and a prediction
    dynamo_item = {
        'id': {
            'S': str(uuid.uuid1())
        },
        'prediction': {
            'S': prediction
        },
    }
    
    # adding all the other features to the record
    for feature in event:
        dynamo_item[feature] = {'N': event[feature]}
    
    
    dynamodb.put_item(
        TableName=TABLE_NAME,
        Item=dynamo_item,
    )
    
    return {
        'statusCode': 200,
        'body': 'Prediction loaded to dynamoDB!'
    }

