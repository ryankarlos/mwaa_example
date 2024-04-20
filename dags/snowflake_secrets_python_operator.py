from airflow import DAG, settings
from airflow.utils.dates import days_ago
from datetime import timedelta
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
import time
from airflow.operators.python import PythonOperator
import logging
from airflow.models import Variable
import snowflake.connector
import os
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
import boto3
import json
from botocore.exceptions import ClientError


def get_secrets():
    # Create a Secrets Manager client
    session = boto3.session.Session()
    region_name = session.region_name
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        pk_secret = client.get_secret_value(
            SecretId="snowflake/private-key"
        )
        conn_vars = client.get_secret_value(
            SecretId="snowflake/conn-vars"
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    pk = pk_secret['SecretString']
    conn_vars = conn_vars['SecretString']
    return pk, conn_vars

def add_snowflake_connection_callable(**kwargs):
    pk, conn_vars = get_secrets()
    conn_vars_dict = json.loads(conn_vars)
    logging.info(conn_vars_dict)
    user = conn_vars_dict["user"],
    account = conn_vars_dict["account"],
    warehouse = conn_vars_dict["warehouse"],
    database = conn_vars_dict["database"],
    schema = conn_vars_dict["schema"],
    role = conn_vars_dict["role"]

    p_key = serialization.load_pem_private_key(
        pk.encode('utf-8'),
        password=None,
        backend=default_backend()
    )

    pkb = p_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption())

    logging.info(pkb)

    ctx = snowflake.connector.connect(
        user=user[0],
        account=account[0],
        private_key=pkb,
        warehouse=warehouse[0],
        database=database[0],
        schema=schema[0],
        role=role
    )

    cs = ctx.cursor()
    try:
        view = "DIM_SPORT"
        cs.execute(f"SELECT TOP 10 * FROM {database[0]}.{schema[0]}.{view}")
        data = cs.fetchall()
        logging.info(data)
    finally:
        cs.close()


default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'depends_on_past': False
}

with DAG(
        dag_id=os.path.basename(__file__).replace(".py", ""),
        default_args=default_args,
        dagrun_timeout=timedelta(hours=2),
        start_date=days_ago(1),
        schedule_interval=None
) as dag:
    add_connection: PythonOperator = PythonOperator(
        task_id="test-snowflake-connection",
        python_callable=add_snowflake_connection_callable
    )

    delay_python_task: PythonOperator = PythonOperator(
        task_id="delay_python_task",
        python_callable=lambda: time.sleep(10)
    )


add_connection >> delay_python_task
