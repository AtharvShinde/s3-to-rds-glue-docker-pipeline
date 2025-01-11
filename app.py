import boto3
import pymysql
import os

def read_s3_data(bucket_name, file_key):
    s3 = boto3.client('s3')
    response = s3.get_object(Bucket=bucket_name, Key=file_key)
    return response['Body'].read().decode('utf-8')

def push_to_rds(data, rds_config):
    try:
        connection = pymysql.connect(
            host=rds_config['host'],
            user=rds_config['user'],
            password=rds_config['password'],
            database=rds_config['database']
        )
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO my_table (data_column) VALUES (%s)", (data,))
        connection.commit()
        connection.close()
    except Exception as e:
        print(f"RDS error: {e}")
        return False
    return True

def push_to_glue(data, glue_table):
    glue = boto3.client('glue')
    response = glue.start_job_run(
        JobName=glue_table,
        Arguments={'--data': data}
    )
    print(f"Glue Job started: {response['JobRunId']}")

if __name__ == "__main__":
    bucket_name = os.getenv('BUCKET_NAME')
    file_key = os.getenv('FILE_KEY')
    rds_config = {
        'host': os.getenv('RDS_HOST'),
        'user': os.getenv('RDS_USER'),
        'password': os.getenv('RDS_PASSWORD'),
        'database': os.getenv('RDS_DATABASE')
    }
    glue_table = os.getenv('GLUE_TABLE')

    data = read_s3_data(bucket_name, file_key)
    if not push_to_rds(data, rds_config):
        push_to_glue(data, glue_table)
