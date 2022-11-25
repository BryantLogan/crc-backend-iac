import json
import boto3

def get_count_handler(event, context):
    client = boto3.client('dynamodb')
    visits = client.get_item(
        TableName='cloud-resume-challenge-db',
        Key={
            'pk':{
            'S': 'Visits'}
            },
            AttributesToGet=[
                'Hits'])
    visit_total = int(visits['Item']['Hits']['N'])
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "*",
            "Access-Control-Allow-Headers": "*",
    },
        "body": json.dumps({
            "message": "success",
            "hits": visit_total
        })
    }

get_count_handler()