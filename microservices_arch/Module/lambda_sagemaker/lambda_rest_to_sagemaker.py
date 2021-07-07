import json
import boto3

#copy the endpoint name
ENDPOINT_NAME = 'sagemaker-scikit-learn-2021-07-07-07-02-33-511'
CONTENT_TYPE = 'text/csv'

runtime = boto3.client('sagemaker-runtime')


def rest_to_sagemaker_handler(event, context):

    for value in event.values():
        try:
            float(value)
        except:
            return value + ' is not a valid float'

    values_str = list(map(str, event.values()))
    payload = ','.join(values_str)
    print('payload: \n', payload)

    # Call the endpoint
    response = runtime.invoke_endpoint(
        EndpointName=ENDPOINT_NAME,
        ContentType=CONTENT_TYPE,
        Body=payload
    )

    resp = response['Body'].read().decode().strip()
    print('response: \n', resp)

    rest_json_response = {
        "statusCode": 200,
        "headers": {
            "my_header": "my_value"
        },
        "body": {
            "prediction" : resp
        },
        "isBase64Encoded": False
    }
    return rest_json_response
