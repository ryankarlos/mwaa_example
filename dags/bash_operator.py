from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

DAG_ID = os.path.basename(__file__).replace(".py", "")


with DAG(
    default_args={
        "owner": "airflow",
        "depends_on_past": False,
    },
    dag_id=DAG_ID
    schedule_interval=timedelta(days=1),
    start_date=datetime(2021, 1, 1),
    catchup=False,
) as dag:
    task1 = BashOperator(
        task_id="bash_task",
        bash_command="echo \"here is the message: '$message'\"",
        env={"message": '{{ dag_run.conf["message"] if dag_run.conf else "" }}'},
    )

    task2 = BashOperator(
        task_id="sleep",
        depends_on_past=False,
        bash_command="sleep 5",
        retries=3,
    )
    task1 >> task2
