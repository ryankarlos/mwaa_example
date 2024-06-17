FROM python
RUN pip install boto3 psycopg2-binary redshift_connector pandas
COPY redshift_conn.py .
CMD [ "python", "redshift.py" ]
