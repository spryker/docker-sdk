import logging
import json
import os

from common.aws.sqs.sqs import AwsSqs
from common.aws.ssm.ssm import AwsSsm
from common.aws.sns.sns import AwsSns
from common.aws.iam.iam import AwsIam
from common.aws.function.function import AwsLambda
from config.config import Config

class Subscription:

    AOP_DLQ_LAMBDA_NAME = '{}_aop_dlq'
    AOP_DL_QUEUE_NAME = '{}_aop_dlq.fifo'
    AOP_DLQ_LAMBDA_ROLE_NAME = 'aop_role_dlq'
    AOP_DLQ_LAMBDA_HANDLER_NAME = 'main'
    AOP_DLQ_LAMBDA_HANDLER_FILE = 'lambda.zip'
    AOP_DLQ_POLICY = 'aop_dlq_policy'
    AOP_SQS_DL_MAX_RECEIVE_COUNT = 3

    @staticmethod
    def sqs_sns_subscription(aops_data, queue_key):
        logging.info('[Sns subscription]')

        sqs = AwsSqs.get_sqs_resource()

        for aop_key,aop_data in aops_data.items():
            logging.info('[Sns subscription] Queue name: {}'.format(aop_data[queue_key]))
            queue = AwsSqs.get_queue(aop_data[queue_key] + '.fifo')
            messages = AwsSqs.receive_queue_messages(queue)
            logging.info('[Sns subscription] Queue message: {}'.format(messages))

            for message in messages:
                try:
                    body = json.loads(message.body)
                except:
                    logging.info('[Sns subscription] Message found with id {}'.format(message.message_id))
                    logging.info('[Sns subscription] Skipping this message, body type miss match')
                    continue

                logging.info('[Sns subscription] Message found with id {}'.format(body['MessageId']))

                if body['Type'] != "SubscriptionConfirmation":
                    logging.info('[Sns subscription] Skipping this message, type missmatch {}'.format(body['Type']))
                    continue

                logging.info('[Sns subscription] Processing the subscription message request')
                subscribeUrl= body['SubscribeURL']
                token = body['Token']
                topicArn = body['TopicArn']

                logging.info('[Sns subscription] Confirming the subscription using message token')
                response = AwsSns.get_sns_client().confirm_subscription(TopicArn=topicArn, Token=token)

                logging.info('[Sns subscription] Deleting the subscription message from the queue')
                AwsSqs.delete_message(message)
                break

        return None

    @classmethod
    def aop_init_dlq_lambda(self):
        logging.info('[Sns subscription] Creating DLQ lambda function and queue')
        logging.info('[Sns subscription] Creating Lambda policy.')
        policy = AwsIam.create_policy(self.AOP_DLQ_POLICY, self.AOP_DLQ_POLICY, self.get_dlq_lambda_policy())
        logging.info('[Sns subscription] Creating Lambda role.')
        aop_dlq_lambda_name = self.AOP_DLQ_LAMBDA_NAME.format(os.environ['SPRYKER_PROJECT_NAME'].lower())
        role = AwsLambda.create_iam_role_for_lambda(self.AOP_DLQ_LAMBDA_ROLE_NAME, policy.arn)
        logging.info('[Sns subscription] Creating Lambda.')

        dl_queue_arn = self.get_dl_queue_arn()

        function = AwsLambda.create_function(
            aop_dlq_lambda_name,
            self.AOP_DLQ_LAMBDA_HANDLER_NAME,
            role,
            self.AOP_DLQ_LAMBDA_HANDLER_FILE
        )

        AwsLambda.create_event_source_mapping(aop_dlq_lambda_name, dl_queue_arn)

        return dl_queue_arn

    @classmethod
    def get_dl_queue_arn(self):
        logging.info('[Sns subscription] Creating DLQ.')
        aop_dl_queue_name = self.AOP_DL_QUEUE_NAME.format(os.environ['SPRYKER_PROJECT_NAME'].lower())
        dl_queue = AwsSqs.get_queue(aop_dl_queue_name)

        if dl_queue is None:
            dl_queue = AwsSqs.create_queue(aop_dl_queue_name)

        dl_queue_url = dl_queue['QueueUrl'] if type(dl_queue) is dict else dl_queue.url
        dl_queue_arn = AwsSqs.get_queue_arn(dl_queue_url)['Attributes']['QueueArn']

        logging.info('[Sns subscription] DLQ arn %s.', dl_queue_arn)

        return dl_queue_arn

    @staticmethod
    def get_dlq_lambda_policy():
         return {
            "Statement": [
                {
                    "Action": [
                        "sqs:*",
                    ],
                    "Effect": "Allow",
                    "Resource": "*",
                    "Sid": "AllowWriteToSQS"
                },
                {
                    "Action": [
                        "ssm:GetParametersByPath",
                        "ssm:GetParameters",
                        "ssm:GetParameter"
                    ],
                    "Effect": "Allow",
                    "Resource": "*",
                    "Sid": "AllowGetParameter"
                }
            ],
            "Version": "2012-10-17"
        }

    @classmethod
    def aop_register_queue(self, aops_data, aops_key, data_key, configs, dl_queue_arn):
        logging.info('[SQS queue registration]')

        for aop_key, aop_data in aops_data[aops_key].items():
            queue = AwsSqs.get_queue(aop_data[data_key] + '.fifo')

            if queue is not None:
                logging.info('[SQS queue registration] "{}" already has a predefined queue'.format(aop_key))
                queue_arn = AwsSqs.get_queue_arn(queue.url)['Attributes']['QueueArn']
                aops_data[aops_key][aop_key].update({'services': {'sqs': {'arn': queue_arn}}})
                continue

            queue = AwsSqs.create_queue(aop_data[data_key] + '.fifo')
            queue_arn = AwsSqs.get_queue_arn(queue['QueueUrl'])['Attributes']['QueueArn']
            queue_policy = self.get_queue_policy(configs, queue_arn)
            dl_queue_policy = self.get_dl_queue_policy(dl_queue_arn)
            responseStatus = AwsSqs.update_queue_attributes(queue['QueueUrl'], queue_arn, queue_policy, dl_queue_policy)

            if responseStatus != 200:
                raise Exception('Cannot update queue attributes {}'.format(aop_key))

            logging.info('[SQS queue registration] "{}" has arn {}'.format(aop_key, queue_arn))
            aops_data[aops_key][aop_key].update({'services': {'SQS': {'ARN': queue_arn}}})

            logging.info('[SQS queue registration] Updated data set - {}'.format(aops_data))

        return aops_data

    @classmethod
    def get_queue_policy(self, configs, queue_arn):
        source_arn = "arn:aws:sns:{}:{}:{}_event_platform.fifo".format(configs[Config.REGION_KEY], configs[Config.ACCOUNT_ID_KEY], configs[Config.ENVIRONMENT_TYPE_KEY])

        return {
              "Statement": [
                {
                  "Sid": "AllowWriteSNSToSQSTenant",
                  "Effect": "Allow",
                  "Principal": {
                    "Service": "sns.amazonaws.com"
                  },
                  "Action": "SQS:SendMessage",
                  "Resource": "{}".format(queue_arn),
                  "Condition": {
                    "ArnLike": {
                      "aws:SourceArn": source_arn
                    }
                  }
                },
                {
                  "Sid": "AllowSQSReceive",
                  "Effect": "Allow",
                  "Principal": {
                    "AWS": "*"
                  },
                  "Action": [
                    "sqs:ReceiveMessage",
                    "sqs:GetQueueUrl",
                    "sqs:DeleteMessage",
                    "sqs:ChangeMessageVisibility"
                  ],
                  "Resource": "{}".format(queue_arn)
                }
              ]
            }

    @classmethod
    def get_dl_queue_policy(self, dl_queue_arn):
        return {
           "maxReceiveCount" : self.AOP_SQS_DL_MAX_RECEIVE_COUNT,
           "deadLetterTargetArn": dl_queue_arn
       }
