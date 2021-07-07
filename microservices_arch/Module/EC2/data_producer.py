import os
os.system('sudo yum update -y')
os.system('sudo yum install -y python-pip')
os.system('pip3 install boto3 pandas')

import boto3
import time
import json
import pandas as pd

kinesis = boto3.client("kinesis", region_name="eu-west-1")
test_data = pd.read_csv("TEST_TO_SHARE.CSV")

test_data['cut'] = test_data['cut'].astype('category')
test_data['color'] = test_data['color'].astype('category')
test_data['clarity'] = test_data['clarity'].astype('category')
test_data = pd.get_dummies(test_data, columns=['cut','color','clarity'])
test_data = test_data.drop(columns='carat_class')
test_data = test_data.fillna(0)

while True:
    print("Producing 5 records...")
    rows = test_data.sample(n=5).to_dict(orient="records")

    kinesis.put_records(
        Records=[
            {
                "Data": json.dumps(x).encode("utf-8"),
                "PartitionKey": "0"
            }
            for x in rows
        ],
        StreamName="diamond-kinesis-stream"
    )

    print("Sleeping 10 seconds...")
    time.sleep(10)
