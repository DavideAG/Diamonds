import json
import urllib3
import boto3
import uuid
import base64
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.client('dynamodb')

API_GATEWAY_ENDPOINT = '${api_url_complete}'
TABLE_NAME = '${dynamodb_prediction_table}'
CONTENT_TYPE = 'text/csv'

def kinesis_to_dynamo_handler(event, context):
    
    logger.info(list(event.items()))
    
    for record in event['Records']:
        decoded_record = json.loads(base64.b64decode(record["kinesis"]["data"]).decode("utf-8"))
        logger.info(decoded_record)
        
        # Getting the prediction from the rest API
        # First we have to create the endpoint
        string = [f'{key}={value}' for key, value in decoded_record.items()]
        params = '&'.join(string)
        
        http = urllib3.PoolManager()
        URI = f'{API_GATEWAY_ENDPOINT}?{params}'
        r = http.request('GET', URI, preload_content=False)
    
        if r.status != 200:
            print('Error. Bad response from API gateway')
            return
        
        r.release_conn()
        result = r.data.decode().strip()
    
        print(f'[RESULT] {result}')
    
        # Parse it from str to json
        prediction = json.loads(result)['body']['prediction']
    
        # adding a rando id and a prediction
        dynamo_item = {
            'PredictionId': {
                'S': str(uuid.uuid1())
            },
            'prediction': {
                'S': prediction
            },
        }
        
        # adding all the other features to the record
        for feature in decoded_record:
            dynamo_item[feature] = {'N': str(decoded_record[feature])}
        
        
        dynamodb.put_item(
            TableName=TABLE_NAME,
            Item=dynamo_item,
        )
    
    return {
        'statusCode': 200,
        'body': 'Prediction loaded to dynamoDB!'
    }
