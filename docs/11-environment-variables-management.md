# Environment variables management

This document describes why and how to manage environment variables on local and cloud environment.


## Why should I use it?
Problem statement is:
- Synchronise the declaration of the environment variables on the local development with those on the cloud/PaaS platform.
- Give a flexible way for the developer to manage the environment variables locally without altering the declaration and without pushing the values into the code repository.

To make the declaration unified, `deploy.yml` contain a section to list the params and the secrets(`enviroment-configuration`) that will be used locally and that will be initialised in AWS Params Store - and eventually AWS Secrets Manager - on the Cloud platform.

## How it works?

The `deploy.yml` file won't contain any values or secrets, except the default values for the params.

In addition, docker/sdk will verify and will generate the files according to those declarations. The generated `.env.docker.local` file will be included natively by docker-compose when running the stack.

### `deploy.yml's` file structure

```yaml

version : '0.2'

...

environment-configuration:                      # Params and secrets section

  secrets:                                     # Secrets' section
    - name: CUSTOM_SECRET_FOR_MY_LOCKER        # Secret's name
      grant: limited | public                  # Secret's grant: 
                                               #     - limited (default): when a secret is flagged
                                               #                as limited (via IAM Role), it will be only
                                               #                readable by the users.
                                               #     - public: if selected, users can read and write the
                                               #               secret  
      bucket: app | scheduler | pipeline | common      
                                               # Secret's bucket : 
                                               #     - app : this secret is only consumed by the apps
                                               #     - scheduler : this secret is only consumed by the scheduler
                                               #     - pipeline : this secret is only consumed by the pipeline
                                               #     - common (default): this secret is consumed by all of the above                                                  
  
  params:                                      # Params' section                                              
    - name: CUSTOM_MAGICAL_PARAM               # Param's name
      bucket: app | scheduler | pipeline | common      
                                               # Param's bucket : 
                                               #     - app : this param is only consumed by the apps
                                               #     - scheduler : this param is only consumed by the scheduler
                                               #     - pipeline : this param is only consumed by the pipeline
                                               #     - common (default): this param is consumed by all of the above
      default: "any"                           # Default value: no restriction on the value's 
                                               #                 type : string, number, json         
      grant: limited | public                  # Param's grant: 
                                               #     - limited: when a param is flagged as limited
                                               #                (via IAM Role), it will be only
                                               #                readable by the users.
                                               #     - public (default): if selected, users can read 
                                               #              and write the param 
```

### What happens on command `bootstrap`

1. Check, is `environment-configuration` declaration?
2. Check, is `.env.docker.local` was exists?
3. Check `.env.docker.local`
4. Check `.gitignore` content

### What happens on command `docker/sdk generate-env`

This command can’t be launched before bootstrap. Its goal is to verify, prepare and generate the local environment file for the local development.

1. Create OR Update `.env.docker.local`
2. Update `.gitignore`

### What happens on command `list-env`

This command will show on stdout all the params keys from the declaration section
```bash
Param: PARAM_1; Bucket: PARAM_BUCKET; Grant: PARAM_GRANT
Param: PARAM_2; Bucket: PARAM_BUCKET; Grant: PARAM_GRANT 
Param: PARAM_n; Bucket: PARAM_BUCKET; Grant: PARAM_GRANT 
Secret: SECRET_1; Bucket: SECRET_BUCKET; Grant: SECRET_GRANT 
Secret: SECRET_2; Bucket: SECRET_BUCKET; Grant: SECRET_GRANT 
Secret: SECRET_n; Bucket: SECRET_BUCKET; Grant: SECRET_GRANT 
```

## Use case(local)

```bash
$ vi deploy.yml                         # edit deploy.yml and adds MY_NEW_VAR into 
                                        # the dedicated section
$ docker/sdk boot
$ docker/sdk generate env
$ vi .env.docker.local                  # change MY_NEW_VAR's default value
$ docker/sdk boot
$ docker/sdk up
... developing
$ export MY_NEW_VAR=some-new-value      # changing to a new value
$ docker/sdk run
```

## Use case(cloud)
1. update `deploy.*.yml` file with environment configuration
2. push changes
3. go to AWS systems-manager and update value for your environment variables
