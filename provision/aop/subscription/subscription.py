import logging
import json

from common.aws.sqs.sqs import AwsSqs
from common.aws.ssm.ssm import AwsSsm
from common.aws.sns.sns import AwsSns

class Subscription:

    @staticmethod
    def sqs_sns_subscription(aops_data, queue_key):
        logging.info('[Sns subscription]')

        sqs = AwsSqs.get_sqs_resource()

        for aop_key,aop_data in aops_data.items():
            logging.info('[Sns subscription] Queue name: {}'.format(aop_data[queue_key]))
            queue = AwsSqs.get_queue(aop_data[queue_key])
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

        #         if body['TopicArn'].split(':')[-1] != args.topic_name:
        #             print("----- Skipping this message, topic missmatch {body[body['TopicArn'].split(':')[-1]]} ----")
        #             continue

                logging.info('[Sns subscription] Processing the subscription message request')
                subscribeUrl= body['SubscribeURL']
                token = body['Token']
                topicArn = body['TopicArn']

        #         print("---- Switching the role to the the Topic account ----")
        #         sts_client = boto3.client('sts')
        #         assumed_role_object=sts_client.assume_role(RoleArn=args.confirmation_role_arn,RoleSessionName="AssumeRoleSnsSubscriptionConfirmation")
        #         print("---- Getting temporary credentials for the assumed role ----")
        #         credentials=assumed_role_object['Credentials']

                logging.info('[Sns subscription] Confirming the subscription using message token')
                response = AwsSns.get_sns_client().get.confirm_subscription(TopicArn=topicArn, Token=token)

                logging.info('[Sns subscription] Deleting the subscription message from the queue')
                AwsSqs.delete_message(message)
                break

        return None

    @classmethod
    def aop_register_queue(self, aops_data, aops_key, data_key):
        logging.info('[SQS queue registration]')

        for aop_key, aop_data in aops_data[aops_key].items():
            queue = AwsSqs.get_queue(aop_data[data_key])

            if queue is not None:
                logging.info('[SQS queue registration] "{}" already has a predefined queue'.format(aop_key))
                queue_arn = AwsSqs.get_queue_arn(queue.url)['Attributes']['QueueArn']
                aops_data[aops_key][aop_key].update({'services': {'sqs': {'arn': queue_arn}}})
                continue

            queue = AwsSqs.create_queue(aop_data[data_key])
            queue_arn = AwsSqs.get_queue_arn(queue['QueueUrl'])['Attributes']['QueueArn']
            logging.info('[SQS queue registration] "{}" has arn {}'.format(aop_key, queue_arn))
            aops_data[aops_key][aop_key].update({'services': {'sqs': {'arn': queue_arn}}})

            logging.info('[SQS queue registration] Updated data set - {}'.format(aops_data))

        return aops_data
