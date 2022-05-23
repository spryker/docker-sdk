#!/usr/bin/env python
import logging
import sys
from multidb import MultiDb
sys.path.append(".")

from common.yml.yml import YamlParser
from common.aws.ssm.ssm import AwsSsm

logging.basicConfig(level=logging.INFO)

def main():
    try:
        MultiDb.provision_logical_dbs(yaml_parser=YamlParser(), aws_ssm=AwsSsm())
    except Exception as e:
        print(e)
        exit()
        logging.error(str(e))
        exit(1)

if __name__ == '__main__':
    main()
