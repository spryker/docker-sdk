import logging
import boto3
from botocore.exceptions import ClientError
import json
import zipfile
import time

from common.aws.iam.iam import AwsIam

class AwsLambda:

    def __init__(self):
        logging.info('[AwsLambda] AwsLambda constructor')

    @staticmethod
    def get_lambda_client():
        return boto3.client('lambda')

    @classmethod
    def create_iam_role_for_lambda(self, iam_role_name, policy_arn):
        """
        Creates an IAM role that grants the Lambda function basic permissions. If a
        role with the specified name already exists, it is used for the demo.

        :param iam_role_name: The name of the role to create.
        :return: The role and a value that indicates whether the role is newly created.
        """
        role = AwsIam.get_iam_role(iam_role_name)

        if role is not None:
            return role

        lambda_assume_role_policy = {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                  "Service": "lambda.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
            }
          ]
        }

        try:
            role = boto3.resource('iam').create_role(
                RoleName=iam_role_name,
                AssumeRolePolicyDocument=json.dumps(lambda_assume_role_policy)
            )

            role.attach_policy(PolicyArn=policy_arn)

            logging.info("[AwsLambda] Created role %s.", role.name)
            logging.info("[AwsLambda] Attached basic execution policy to role %s.", role.name)
        except ClientError as error:
            if error.response['Error']['Code'] == 'EntityAlreadyExists':
                role = boto3.resource('iam').Role(iam_role_name)
                logging.warning("[AwsLambda] The role %s already exists. Using it.", iam_role_name)
            else:
                logging.exception(
                    "[AwsLambda] Couldn't create role %s or attach policy '%s'",
                    iam_role_name, policy_arn)
                raise

        return role

    @classmethod
    def create_function(self, function_name, handler_name, iam_role, deployment_package):
        """
        Deploys a Lambda function.

        :param function_name: The name of the Lambda function.
        :param handler_name: The fully qualified name of the handler function. This
                             must include the file name and the function name.
        :param iam_role: The IAM role to use for the function.
        :param deployment_package: The deployment package that contains the function
                                   code in .zip format.
        :return: The Amazon Resource Name (ARN) of the newly created function.
        """

        logging.info("[AwsLambda] Creating of Lambda function %s.", function_name)

        try:
            with open('aop/' + deployment_package, 'rb') as f:
            	zipped_code = f.read()

            function = self.get_function(function_name)

            if function is not None:
                return function['Configuration']['FunctionArn']

            logging.info('[AwsLambda] Sleep 10. Due to Role apply....')
            time.sleep(10)

            response = self.get_lambda_client().create_function(
                FunctionName=function_name,
                Description="",
                Runtime='go1.x',
                Role=iam_role.arn,
                Handler=handler_name,
                Code={'ZipFile': zipped_code},
                Publish=True,
                Environment={
                        'Variables': {
                            'PARAMETER_STORE_SLACK_WH_URL': 'PARAMETER_STORE_SLACK_WH_URL',
                        }
                    },)
            function_arn = response['FunctionArn']
            waiter = self.get_lambda_client().get_waiter('function_active_v2')
            waiter.wait(FunctionName=function_name)
            logging.info("[AwsLambda] Created function '%s' with ARN: '%s'.", function_name, response['FunctionArn'])
        except ClientError:
            logging.error("[AwsLambda] Couldn't create function %s.", function_name)
            raise
        else:

            logging.info("[AwsLambda] Lambda function '%s' has been created.", function_name)

            return function_arn

    @classmethod
    def get_function(self, function_name):
        """
        Gets data about a Lambda function.

        :param function_name: The name of the function.
        :return: The function data.
        """
        response = None
        try:
            response = self.get_lambda_client().get_function(FunctionName=function_name)
        except ClientError as err:
            if err.response['Error']['Code'] == 'ResourceNotFoundException':
                logging.info("[AwsLambda] Function %s does not exist.", function_name)
            else:
                logging.error(
                    "[AwsLambda] Couldn't get function %s. Here's why: %s: %s", function_name,
                    err.response['Error']['Code'], err.response['Error']['Message'])
                raise

        return response

    @classmethod
    def create_event_source_mapping(self, function_name, dl_queue_arn):
        try:
            self.get_lambda_client().create_event_source_mapping(
                FunctionName=function_name,
                EventSourceArn=dl_queue_arn
            )
        except ClientError as error:
            if error.response['Error']['Code'] == 'ResourceConflictException':
                return None
            else:
                logging.exception(error)
                raise
