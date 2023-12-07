import os
import time

import boto3


def lambda_handler(event, context):
    cluster_id = event["detail"]["clusterId"]
    allocationId = os.environ['EIP_ALLOC_ID']
    exc_time = 180
    time_cnt = 0

    client = boto3.client("emr")
    ec2 = boto3.client("ec2")
    response = client.list_instances(
        ClusterId=cluster_id, InstanceGroupTypes=["MASTER"]
    )
    ec2_id_primary_node = response["Instances"]
    while True:
        if not ec2_id_primary_node:
            time.sleep(30)
            time_cnt += 30
            if time_cnt > exc_time:
                print("Couldnt obtain ec2 master instance id")
                break
            else:
                response = client.list_instances(
                    ClusterId=cluster_id, InstanceGroupTypes=["MASTER"]
                )
                ec2_id_primary_node = response["Instances"]
        else:
            ec2_id_primary_node = ec2_id_primary_node[0]["Ec2InstanceId"]
            break
    ec2.associate_address(InstanceId=ec2_id_primary_node, AllocationId=allocationId)
