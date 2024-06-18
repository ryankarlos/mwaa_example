FROM public.ecr.aws/lambda/python:3.11
COPY dags/requirements.txt .
RUN pip install -r requirements.txt
COPY dags/utils/execute_redshift_query.py .
CMD [ "python", "execute_redshift_query.py" ]