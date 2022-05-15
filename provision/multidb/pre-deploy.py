#!/usr/bin/env python
from db.db import MultiDb
from pathlib import Path
import logging
import sys
path_root = Path(__file__).parents[1]
sys.path.append(str(path_root))
from common.yml.yml import YamlParser
from common.aws.ssm.ssm import AwsSsm

logging.basicConfig(level=logging.INFO)

def main():
    try:
        MultiDb.provision_logical_dbs(yaml_parser=YamlParser(), aws_ssm=AwsSsm())
    except Exception as e:
        logging.error(str(e))
        exit(1)


if __name__ == '__main__':
    main()
