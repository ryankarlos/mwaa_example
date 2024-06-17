FROM python
RUN pip install boto3 psycopg2-binary redshift_connector pandas
COPY redshift.py .
CMD [ "python", "redshift.py" ]
