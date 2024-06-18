
from airflow.models import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
import json
import boto3
from utils.execute_redshift_query import get_ssm_params,  python_connector_redshift


with DAG(
    dag_id=f"example_dag_redshift",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False
) as dag:
    ecs_params: dict = json.loads(get_ssm_params(name="ECS"))
    network_params: dict = json.loads(get_ssm_params(name="NETWORK"))
    client=boto3.client('ecs')
    service=client.describe_services(cluster=ecs_params['cluster_name'],services=[ecs_params['service']])
    subnets = boto3.resource("ec2").subnets.filter(
        Filters=[{"Name": "vpc-id", "Values": [network_params["vpc_id"]]}]
    )

    subnet_ids = [sn.id for sn in subnets]
    client = boto3.client('ec2')
    response = client.describe_security_groups(
        Filters=[
            dict(Name='group-name', Values=[network_params["security_group_name"]])
        ]
    )
    security_group_id = response['SecurityGroups'][0]['GroupId']

    my_python_task = PythonOperator(
        task_id="copy_s3_to_redshift", dag=dag, python_callable=python_connector_redshift,
    )

    run_ecs_task = EcsRunTaskOperator(
        task_id="run_ecs_task",
        dag=dag,
        cluster=ecs_params['cluster_name'],
        task_definition=ecs_params['task_definition_arn'],
        launch_type=ecs_params['launch_type'],
        overrides={
            "containerOverrides": [],
        },
        network_configuration={'awsvpcConfiguration': {'subnets': subnet_ids, 'securityGroups': [security_group_id], 'assignPublicIp': 'ENABLED'}},
        awslogs_group=ecs_params["logs_group"],
        awslogs_region="us-east-1",
        awslogs_stream_prefix=ecs_params["logs_stream_prefix"],
    )

    my_python_task >>  run_ecs_task
