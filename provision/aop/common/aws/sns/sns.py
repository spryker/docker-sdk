import logging
import boto3
from botocore.exceptions import ClientError

class AwsSns:
    def __init__(self):
        logging.info('[AOP] AwsSns constructor')

    @staticmethod
    def get_sns_client():
        return boto3.client('sns')
