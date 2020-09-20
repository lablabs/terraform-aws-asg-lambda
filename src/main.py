"""
AWS ASG lambda
"""

import os
from datetime import datetime

import boto3
from botocore.exceptions import ClientError

ec2_client = boto3.client("ec2")
asg_client = boto3.client("autoscaling")

EIP = os.environ["EIP"]
ENI = os.environ["ENI"]
EBS = os.environ["EBS"]

EIP_TAG_FILTER_NAME = os.environ["EIP_TAG_FILTER_NAME"]
EIP_TAG_FILTER_VALUE = os.environ["EIP_TAG_FILTER_VALUE"]

ENI_TAG_FILTER_NAME = os.environ["ENI_TAG_FILTER_NAME"]
ENI_TAG_FILTER_VALUE = os.environ["ENI_TAG_FILTER_VALUE"]

EBS_TAG_FILTER_NAME = os.environ["EBS_TAG_FILTER_NAME"]
EBS_TAG_FILTER_VALUE = os.environ["EBS_TAG_FILTER_VALUE"]
EBS_DEVICE_NAME = os.environ["EBS_DEVICE_NAME"]


def handle(event, context):
    """
    Lambda handler
    """
    if event["detail-type"] == "EC2 Instance-launch Lifecycle Action":
        log("Lambda environment variables: {}".format(os.environ))
        log("Lambda event: {}".format(event))
        log("Lambda context: {}".format(context))
        try:
            instance_id = get_instance_id(event)

            if EIP == "true":
                eip_allocation_id = get_free_eip_allocation_id()
                attach_eip(eip_allocation_id, instance_id)
            if ENI == "true":
                eni_id = get_free_eni_id(instance_id)
                attach_eni(eni_id, instance_id)
            if EBS == "true":
                ebs_volume_id = get_free_ebs_volume_id(instance_id)
                attach_ebs(ebs_volume_id, instance_id)

            complete_lifecycle_action_success(event)

        except (EventDataError, ResourceNotFound, ResourceAttachError) as err:
            log("{}: {}".format(err.description, err.message))
            complete_lifecycle_action_failure(event)


def get_free_eips():
    """
    Get all free EIP
    """
    eips = None

    try:
        result = ec2_client.describe_addresses(
            Filters=[
                {
                    "Name": "tag:{}".format(EIP_TAG_FILTER_NAME),
                    "Values": [EIP_TAG_FILTER_VALUE],
                },
            ]
        )

        eips = [eip for eip in result["Addresses"] if "AssociationId" not in eip]

    except ClientError as err:
        log("Error describing the addresses error: {}".format(err.response["Error"]))

    if not eips or len(eips) == 0:
        raise ResourceNotFound("EIP", "No free EIP has been found")

    return eips


def get_free_eip_allocation_id():
    """
    Get free EIP association id by tag
    """
    eips = get_free_eips()
    return sorted(eips, key=lambda x: x["AllocationId"])[0]["AllocationId"]


def attach_eip(eip_allocation_id, instance_id):
    """
    Attach EIP to the instance.
    """
    association_state = None
    log(
        "Attaching '{}' EIP address to '{}' instance".format(
            eip_allocation_id, instance_id
        )
    )
    if eip_allocation_id and instance_id:
        try:
            result = ec2_client.associate_address(
                AllocationId=eip_allocation_id, InstanceId=instance_id
            )
            association_state = result["AssociationId"]
            log("EIP association response: {}".format(result))
        except ClientError as err:
            log("Error attaching EIP address failed: {}".format(err.response["Error"]))

    if not association_state:
        raise ResourceAttachError("EIP")

    return association_state


def get_instance_subnet_id(instance_id):
    """
    Get ID of subnet where the instance is running.
    """
    vpc_subnet_id = None
    try:
        result = ec2_client.describe_instances(InstanceIds=[instance_id])
        vpc_subnet_id = result["Reservations"][0]["Instances"][0]["SubnetId"]

    except ClientError as err:
        log(
            "Error describing the instance {}: {}".format(
                instance_id, err.response["Error"]
            )
        )

    if not vpc_subnet_id:
        raise ResourceNotFound(
            "Subnet",
            "No subnet for instance ID '{}' has been found".format(instance_id),
        )

    return vpc_subnet_id


def get_instance_az(instance_id):
    """
    Get AZ name where the instance is running.
    """
    instance_az = None
    try:
        result = ec2_client.describe_instances(InstanceIds=[instance_id])
        instance_az = result["Reservations"][0]["Instances"][0]["Placement"][
            "AvailabilityZone"
        ]

    except ClientError as err:
        log(
            "Error describing the instance {}: {}".format(
                instance_id, err.response["Error"]
            )
        )

    if not instance_az:
        raise ResourceNotFound(
            "AZ", "No AZ for instance ID '{}' has been found".format(instance_id)
        )

    return instance_az


def get_free_enis(instance_id):
    """
    Get all free NetworkInterfaces in the instance subnet with the tag.
    """
    subnet_id = get_instance_subnet_id(instance_id)

    enis = None
    try:
        result = ec2_client.describe_network_interfaces(
            Filters=[
                {
                    "Name": "tag:{}".format(ENI_TAG_FILTER_NAME),
                    "Values": [ENI_TAG_FILTER_VALUE],
                },
                {"Name": "subnet-id", "Values": [subnet_id]},
                {"Name": "status", "Values": ["available"]},
            ]
        )
        enis = result["NetworkInterfaces"]
        log("Free ENI IDs: {}".format([eni["NetworkInterfaceId"] for eni in enis]))

    except ClientError as err:
        log(
            "Error describing the instance {}: {}".format(
                subnet_id, err.response["Error"]
            )
        )

    if not enis or len(enis) == 0:
        raise ResourceNotFound(
            "ENI", "No ENI for subnet ID '{}' has been found".format(subnet_id)
        )

    return enis


def get_free_eni_id(instance_id):
    """
    Get free ENI id in the instance subnet.
    """
    enis = get_free_enis(instance_id)
    return sorted(enis, key=lambda x: x["NetworkInterfaceId"])[0]["NetworkInterfaceId"]


def attach_eni(eni_id, instance_id):
    """
    Attach ENI to the instance.
    """
    attachment_state = None

    log("Attaching '{}' ENI to '{}' instance".format(eni_id, instance_id))
    if eni_id and instance_id:
        try:
            result = ec2_client.attach_network_interface(
                NetworkInterfaceId=eni_id, InstanceId=instance_id, DeviceIndex=1
            )
            attachment_state = result["AttachmentId"]
            log("ENI attachment response: {}".format(result))
        except ClientError as err:
            log("Error attaching network interface: {}".format(err.response["Error"]))

    if not attachment_state:
        raise ResourceAttachError("ENI")

    return attachment_state


def get_free_ebs_volumes(instance_id):
    """
    Get all free EBS volumes by instance AZ
    """
    instance_az = get_instance_az(instance_id)

    volumes = None
    try:
        result = ec2_client.describe_volumes(
            Filters=[
                {
                    "Name": "tag:{}".format(EBS_TAG_FILTER_NAME),
                    "Values": [EBS_TAG_FILTER_VALUE],
                },
                {"Name": "availability-zone", "Values": [instance_az]},
                {"Name": "status", "Values": ["available"]},
            ]
        )
        volumes = result["Volumes"]
        log("Free EBS volumes: {}".format(volumes))

    except ClientError as err:
        log("Error describing the EBS volumes {}".format(err.response["Error"]))

    if not volumes or len(volumes) == 0:
        raise ResourceNotFound(
            "EBS", "No EBS volume for instance '{}' has been found".format(instance_id)
        )

    return volumes


def get_free_ebs_volume_id(instance_id):
    """
    Get free EBS volume id
    """
    volumes = get_free_ebs_volumes(instance_id)
    return sorted(volumes, key=lambda x: x["VolumeId"])[0]["VolumeId"]


def attach_ebs(ebs_id, instance_id):
    """
    Attach EBS volume to the instance.
    """
    attachment_state = None
    log("Attaching '{}' EBS volume to '{}' instance".format(ebs_id, instance_id))
    if ebs_id and instance_id:
        try:
            result = ec2_client.attach_volume(
                VolumeId=ebs_id, InstanceId=instance_id, Device=EBS_DEVICE_NAME
            )
            attachment_state = result["State"]
            log("EBS attachment response: {}".format(result))
        except ClientError as err:
            log("Error attaching EBS volume: {}".format(err.response["Error"]))

    if not attachment_state:
        raise ResourceAttachError("EBS")

    return attachment_state


def complete_lifecycle_action_success(event):
    """
    Lifecycle success
    """
    return complete_lifecycle_action(event, lifecycle_action_result="CONTINUE")


def complete_lifecycle_action_failure(event):
    """
    Lifecycle failure
    """
    return complete_lifecycle_action(event, lifecycle_action_result="ABANDON")


def complete_lifecycle_action(event, lifecycle_action_result):
    """
    Lifecycle action
    """
    assert lifecycle_action_result in ["CONTINUE", "ABANDON"]
    try:
        asg_client.complete_lifecycle_action(
            LifecycleHookName=event["detail"]["LifecycleHookName"],
            AutoScalingGroupName=event["detail"]["AutoScalingGroupName"],
            InstanceId=get_instance_id(event),
            LifecycleActionResult=lifecycle_action_result,
        )
        log(
            "Lifecycle hook {}ed for: {}".format(
                lifecycle_action_result, get_instance_id(event)
            )
        )
    except ClientError as err:
        log(
            "Error completing life cycle hook for instance {}: {}".format(
                get_instance_id(event), err.response["Error"]
            )
        )
        log('{"Error": "1"}')


def get_instance_id(event):
    """
    Get instance id
    """
    try:
        instance_id = event["detail"]["EC2InstanceId"]
        log("event['detail']['EC2InstanceId]' = {}".format(instance_id))
        return instance_id
    except KeyError as err:
        log("Key error: event={}".format(event))
        raise EventDataError("Cannot read EC2 instance ID form event detail") from err


def log(error):
    """
    Logging
    """
    print("{}Z {}".format(datetime.utcnow().isoformat(), error))


class EventDataError(Exception):
    """Raised when event data are not formatted as expected"""

    description = "Event data error"

    def __init__(self, message):
        self.message = message
        super().__init__(self.message)


class ResourceNotFound(Exception):
    """Raised when resource is not found"""

    description = "Resource not found error"

    def __init__(self, resource_type, message):
        self.resource_type = resource_type
        self.message = message
        super().__init__(self.message)


class ResourceAttachError(Exception):
    """Raised when resource attachment fails"""

    description = "Resource attachment error"

    def __init__(self, resource_type):
        self.resource_type = resource_type
        self.message = "Resource {} has not been attached successfully".format(
            resource_type
        )
        super().__init__(self.message)
