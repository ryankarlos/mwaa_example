# mwaa_example
Airflow deployment example on AWS using Amazon Managed Workflows for Apache Airflow (MWAA)

### Build and push the docker image to ECR


```bash
chmod +x docker_build_ecr.sh

./docker_build_ecr.sh -i ecs-redshift -a <insert-account-id> -r us-east-1
```

# Test the docker container locally for debugging 

```bash
docker run -e AWS_DEFAULT_REGION='us-east-1' -e AWS_ACCESS_KEY_ID=<ACCESS-KEY-ID> -e AWS_SECRET_ACCESS_KEY=<SECRET-ACCESS-KEY> <ECR-REPO-URI>
```