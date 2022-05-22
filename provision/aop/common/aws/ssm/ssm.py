import logging
import boto3
import os
import json

from botocore.exceptions import ClientError

class AwsSsm:
    PARAM_STORE_CODEBUILD = "codebuild/base_task_definition"
    PARAM_STORE_SECRET = "custom-secrets"

    @staticmethod
    def ssm_get_parameter_path(parameter_store_path):
        if parameter_store_path:
            return "/{}/{}/".format(os.environ['SPRYKER_PROJECT_NAME'], parameter_store_path)

        return parameter_store_path

    @classmethod
    def update_environment_variables(self, env_vars, path):
        for env_var_key,env_var_data in env_vars.items():
            self.ssm_put_parameter(env_var_key, json.dumps(env_var_data), 'SecureString', path)

    @classmethod
    def ssm_get_parameter(self, parameter_name, parameter_store_path = '', with_decryption = True):
        """Get parameter details in AWS SSM
        :param parameter_name: Name of the parameter to fetch details from SSM
        :param with_decryption: return decrypted value for secured string params, ignored for String and StringList
        :return: Return parameter details if exist else None
        """
        ssm_client = boto3.client('ssm')

        try:
            result = ssm_client.get_parameter(
                Name=self.ssm_get_parameter_path(parameter_store_path) + parameter_name,
                WithDecryption=with_decryption
            )
        except ClientError as e:
            return None
        return result

    @classmethod
    def ssm_put_parameter(self, parameter_name, parameter_value, parameter_type, parameter_store_path = ''):
        """Creates new parameter in AWS SSM
        :param parameter_name: Name of the parameter to create in AWS SSM
        :param parameter_value: Value of the parameter to create in AWS SSM
        :param parameter_type: Type of the parameter to create in AWS SSM ('String'|'StringList'|'SecureString')
        :return: Return version of the parameter if successfully created else None
        """
        ssm_client = boto3.client('ssm')

        try:
            result = ssm_client.put_parameter(
                Name=self.ssm_get_parameter_path(parameter_store_path) + parameter_name,
                Value=parameter_value,
                Type=parameter_type,
                Overwrite=True
            )
        except ClientError as e:
            logging.error(e)
            return None
        return result['Version']
