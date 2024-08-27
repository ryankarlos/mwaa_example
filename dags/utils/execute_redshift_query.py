
import boto3
import redshift_connector
import json
import argparse


def get_ssm_params(name, parent_path="/mwaa/redshift"):
    ssm_client = boto3.client('ssm')
    return ssm_client.get_parameter(Name=f"{parent_path}/{name}")['Parameter']['Value']


def python_connector_redshift(ecs_query=False):
    secret_client = boto3.client('secretsmanager')
    response = secret_client.get_secret_value(
        SecretId=get_ssm_params("SECRET_ID")
    )
    secrets = json.loads(response['SecretString'])

    # Connect to the cluster

    with redshift_connector.connect(
        host=get_ssm_params("HOST"),
        database=get_ssm_params("DB"),
        port=get_ssm_params("PORT"),
        db_user='awsuser',
        password='',
        user='', 
        cluster_identifier=get_ssm_params("CLUSTER_ID"),
        profile='default') as conn:
        sql_params = json.loads(get_ssm_params("SQL_PARAMS"))
        # needs to be included to commit the transactions to table
        # otherwise you will empty rows when uery from redshift query editor
        conn.rollback()
        conn.autocommit = True
        conn.run("VACUUM")
        with conn.cursor() as cursor:
            schema = get_ssm_params("SCHEMA")
            table = get_ssm_params("TABLE")
            s3_uri = get_ssm_params(name="S3_URI")
            if ecs_query:
                cursor.execute(
                    f'CREATE OR REPLACE VIEW old_expensive_houses AS SELECT * FROM {schema}.{table} '
                    f'WHERE median_house_value >= {sql_params["median_house_value"]} '
                    f'AND housing_median_age >= {sql_params["housing_median_age"]} '
                    f'AND population > {sql_params["population"]} '
                    f'WITH NO SCHEMA BINDING;')
                cursor.execute("SELECT * FROM old_expensive_houses")
            else:
                cursor.execute(f"TRUNCATE {schema}.{table};")
                query = f"""
                COPY {schema}.{table} FROM '{s3_uri}' 
                IAM_ROLE 'arn:aws:iam::376337229415:role/RedshiftRole' 
                DELIMITER ',' IGNOREHEADER 1 
                REGION AS 'us-east-1'
                """
                print(query)
                cursor.execute(query)
                cursor.execute(f"select * from {schema}.{table}")
            df = cursor.fetch_dataframe()
            print(df)
        conn.autocommit = False


def parse_command_line_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ecs_query", default=True, type=bool,
                        help="whether to switch to the redshift query to run on ecs")
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    args = parse_command_line_args()
    python_connector_redshift(args.ecs_query)

