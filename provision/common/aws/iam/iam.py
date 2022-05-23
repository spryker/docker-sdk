import logging
import boto3
from botocore.exceptions import ClientError
import json

class AwsIam:

    def __init__(self):
        logging.info('[AwsIam] AwsIam constructor')

    @staticmethod
    def get_iam_resource():
        return boto3.resource('iam')

    @classmethod
    def get_iam_role(self, iam_role_name):
        """
        Get an AWS Identity and Access Management (IAM) role.

        :param iam_role_name: The name of the role to retrieve.
        :return: The IAM role.
        """
        role = None
        try:
            temp_role = self.get_iam_resource().Role(iam_role_name)
            temp_role.load()
            role = temp_role
            logging.info("[AwsIam] Got IAM role %s with arn %s", role.name, role.arn)
        except ClientError as err:
            if err.response['Error']['Code'] == 'NoSuchEntity':
                logging.info("[AwsIam] IAM role %s does not exist.", iam_role_name)
            else:
                logging.error(
                    "[AwsIam] Couldn't get IAM role %s. Here's why: %s: %s", iam_role_name,
                    err.response['Error']['Code'], err.response['Error']['Message'])
                raise

        return role

    @classmethod
    def create_policy(self, name, description, policy):
        """
        Creates a policy that contains a single statement.

        :param name: The name of the policy to create.
        :param description: The description of the policy.
        :return: The newly created policy.
        """
        try:
            policy = self.get_iam_resource().create_policy(
                PolicyName=name, Description=description,
                PolicyDocument=json.dumps(policy))
            logging.info("[AwsIam] Created policy %s.", policy.arn)

            return policy
        except ClientError as error:
            if error.response['Error']['Code'] == 'EntityAlreadyExists':
                logging.info("[AwsIam] Policy '%s' already created.", name)
                policies = self.list_policies('Local')
                for policy in policies:
                    str_policy = str(policy)
                    if name in str_policy:
                        logging.info("[AwsIam] Found policy with name '%s'.", name)
                        return policy
            else:
                logging.exception("[AwsIam] Couldn't create policy %s.", name)
                raise

    @classmethod
    def list_policies(self, scope):
        """
        Lists the policies in the current account.

        :param scope: Limits the kinds of policies that are returned. For example,
                      'Local' specifies that only locally managed policies are returned.
        :return: The list of policies.
        """
        try:
            policies = list(self.get_iam_resource().policies.filter(Scope=scope))
            logging.info("[AwsIam] Got %s policies in scope '%s'.", len(policies), scope)
        except ClientError:
            logging.exception("[AwsIam] Couldn't get policies for scope '%s'.", scope)
            raise
        else:
            return policies
