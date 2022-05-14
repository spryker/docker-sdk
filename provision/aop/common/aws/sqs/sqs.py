import logging
import boto3
from botocore.exceptions import ClientError

class AwsSqs:
    def __init__(self):
        logging.info('[AOP] AwsSqs constructor')

    @staticmethod
    def get_sqs_resource():
        return boto3.resource('sqs')

    @staticmethod
    def get_sqs_client():
        return boto3.client('sqs')

    @classmethod
    def get_queue(self, name):
        """
        Gets an SQS queue by name.

        :param name: The name that was used to create the queue.
        :return: A Queue object.
        """
        try:
            queue = self.get_sqs_resource().get_queue_by_name(QueueName=name)
            logging.info("Got queue '%s' with URL=%s", name, queue.url)
        except ClientError as error:
            logging.info("Couldn't get queue named %s.", name)

            return None
        else:
            return queue

    @classmethod
    def get_queue_arn(self, dlq_url):
        """
        Returns the ARN of the Dead Letter Queue.
        """
        try:
            response = self.get_sqs_client().get_queue_attributes(QueueUrl=dlq_url, AttributeNames=['QueueArn'])
        except ClientError:
            logging.exception('Could not return DLQ ARN - {dlq_url}.')
            raise
        else:
            return response

    @classmethod
    def create_queue(self, name, attributes=None):
        """
        Creates an Amazon SQS queue.

        :param name: The name of the queue. This is part of the URL assigned to the queue.
        :param attributes: The attributes of the queue, such as maximum message size or
                           whether it's a FIFO queue.
        :return: A Queue object that contains metadata about the queue and that can be used
                 to perform queue operations like sending and receiving messages.
        """
        if not attributes:
            attributes = {}

        try:
            queue = self.get_sqs_client().create_queue(
                QueueName=name,
                Attributes=attributes
            )
            logging.info("Created queue '%s' with URL=%s", name, queue['QueueUrl'])
        except ClientError as error:
            logging.info("Couldn't create queue named '%s'.", name)
            logging.exception(error)
            return None
        else:
            return queue

    @classmethod
    def receive_queue_messages(self, queue):
        return queue.receive_messages(QueueUrl=queue.url, AttributeNames=['All'], MaxNumberOfMessages=10, VisibilityTimeout=10,WaitTimeSeconds=5)

    @classmethod
    def delete_message(self, message):
        self.get_sqs_client().delete_message(QueueUrl=message.queue_url, ReceiptHandle=message.receipt_handle)
