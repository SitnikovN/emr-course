import os

import boto3


def delete_folder_contents(s3, bucket_name, folder_prefix):
    objects_to_delete = s3.list_objects_v2(Bucket=bucket_name, Prefix=folder_prefix)
    delete_dict = {
        "Objects": [
            {"Key": obj["Key"]}
            for obj in objects_to_delete.get("Contents", [])
            if obj["Key"] != f'{folder_prefix}/'
        ]
    }
    if delete_dict["Objects"]:
        s3.delete_objects(Bucket=bucket_name, Delete=delete_dict)


def lambda_handler(event, context):
    s3client = boto3.client("s3")
    bucket = os.environ['BUCKET_NAME']
    prefix = os.environ['TGT_PREFIX']
    delete_folder_contents(s3client, bucket, prefix)
    print('SUCCESS')
