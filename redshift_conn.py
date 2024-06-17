
import boto3
import redshift_connector
import json


def get_ssm_params(name, parent_path="/mwaa/redshift"):
    ssm_client = boto3.client('ssm')
    return ssm_client.get_parameter(Name=f"{parent_path}/{name}")['Parameter']['Value']


def python_connector_redshift():
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
        user=secrets['username'],
        password=secrets['password']) as conn:
        sql_params = json.loads(get_ssm_params("SQL_PARAMS"))
        schema = get_ssm_params("SCHEMA")
        table = get_ssm_params("TABLE")
        with conn.cursor() as cursor:
            cursor.execute(f'SELECT * FROM {schema}.{table} WHERE median_house_value > {sql_params["median_house_value"]} '
                           f'AND housing_median_age >= {sql_params["housing_median_age"]} AND '
                           f'population > {sql_params["population"]}')
            df = cursor.fetch_dataframe()
            print(df)

python_connector_redshift()
