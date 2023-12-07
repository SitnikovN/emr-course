import typing as t

import boto3


def get_running_clusters_ids(emr_client) -> t.Optional[t.List[str]]:
    resp = emr_client.list_clusters(ClusterStates=["RUNNING", "WAITING"])["Clusters"]
    try:
        return [cluster["Id"] for cluster in resp]
    except TypeError:
        return []


def get_emr_master_node_ec2_id(emr_client, cluster_id) -> str:
    resp = emr_client.list_instances(
        ClusterId=cluster_id, InstanceGroupTypes=["MASTER"]
    )
    master_node = resp["Instances"][0]
    return master_node["Ec2InstanceId"]


def get_ec2_env_tag(ec2_client, ec2_inst_id, tag_key):
    tags = ec2_client.describe_tags(
        Filters=[{"Name": "resource-id", "Values": [ec2_inst_id]}]
    )["Tags"]
    for tag in tags:
        if tag["Key"] == tag_key:
            return tag["Value"]


def lambda_handler(event, context):
    emr = boto3.client("emr")
    ec2 = boto3.client("ec2")
    tag_key = "env"
    emr_cluster_ids = get_running_clusters_ids(emr)
    for cluster_id in emr_cluster_ids:
        ec2_primary_id = get_emr_master_node_ec2_id(emr, cluster_id)
        env = get_ec2_env_tag(ec2, ec2_primary_id, tag_key)
        if env == "PROD":
            return {'cluster_id': cluster_id}
