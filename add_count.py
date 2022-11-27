import json
import boto3

def add_count_handler(event, context):
    client = boto3.client('dynamodb')
    response = client.update_item(
        TableName='crc-db-table',
        Key={
            'pk':{
                'S': 'Visits'}
        },
        UpdateExpression= "SET Hits = Hits + :incr",
        ExpressionAttributeValues ={
            ':incr': {'N': '1'}
            },
        ReturnValues="UPDATED_NEW",
    )
    responseMsg = {
    'statusCode': 200,
    'headers': {
# "Content-Type": "application/json",
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': '*',
    },
    "body": json.dumps({
        "message": "success",
        "count": response['Attributes']['Hits']['N']
    }),
}
    return responseMsg