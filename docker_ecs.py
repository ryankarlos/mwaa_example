from airflow import DAG
from airflow.providers.amazon.aws.operators.ecs import EcsRunTaskOperator
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago
import os
import boto3

CLUSTER_NAME = "demo-cluster"
CONTAINER_NAME="mwaa-ecs-demo-container"
LAUNCH_TYPE = "FARGATE"


with DAG(
    dag_id="test_ecs_fargate_dag",
    schedule_interval=None,
    catchup=False,
    start_date=days_ago(1),
) as dag:
    client=boto3.client('ecs')
    services=client.list_services(cluster=CLUSTER_NAME,launchType=LAUNCH_TYPE)
    service=client.describe_services(cluster=CLUSTER_NAME,services=services['serviceArns'])

    ecs_operator_task = EcsRunTaskOperator(
        task_id = "ecs_operator_task",
        dag=dag,
        cluster=CLUSTER_NAME,
        task_definition=service['services'][0]['taskDefinition'],
        network_configuration=service['services'][0]['networkConfiguration'],
        launch_type=LAUNCH_TYPE,
        awslogs_group="mwaa-ecs-zero",
        awslogs_stream_prefix=f"ecs/{CONTAINER_NAME}",
        overrides={
            "containerOverrides":[
                {
                    "name":CONTAINER_NAME,
                    "command":["ls", "-l", "/"],
                },
            ],
        },
    )

