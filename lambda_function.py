import requests
import json
import boto3
import os 


JOB_TITLE = os.environ['job_title']
JOB_TITLE = JOB_TITLE.lower()

SENDER_EMAIL = os.environ['sender_email']
RECEIVER_EMAIL = os.environ['receiver_email']


dynamodb = boto3.resource('dynamodb')
table_name = os.environ['dynamodb_table_name']
table = dynamodb.Table(table_name)


def update_count(company_name):
    # Check if the item exists
    response = table.get_item(
        Key={'Company-Name': company_name},
        ProjectionExpression='count_of_days_since_first_occurrence'
    )
    item = response.get('Item')

    if item:
        # Item exists, increment the attribute
        response = table.update_item(
            Key={
                'Company-Name': company_name
            },
            UpdateExpression='SET #count_of_days_since_first_occurrence = #count_of_days_since_first_occurrence + :incr',
            ExpressionAttributeNames={
                '#count_of_days_since_first_occurrence': 'count_of_days_since_first_occurrence'
            },
            ExpressionAttributeValues={
                ':incr': 1
            },
            ReturnValues='UPDATED_NEW'
        )
        print("update response:", response)
        return int(response['Attributes']['count_of_days_since_first_occurrence'])
    else:
        # Item does not exist, create it with initial value
        response = table.put_item(
            Item={
                'Company-Name': company_name,
                'count_of_days_since_first_occurrence': 1
            }
        )
        print("put response:", response)
        return 1


def parse_career_pages(companies):
    results = {}
    
    for company_name, company_url in companies.items():
        response = requests.get(company_url)
        content = response.text.lower()
        
        if JOB_TITLE in content:
            count_of_days_since_first_occurrence = update_count(company_name)
            results[company_name] = {'url': company_url, 'result': 'yes', 'count': count_of_days_since_first_occurrence}
        else:
            results[company_name] = {'url': company_url, 'result': 'no', 'count': 0}
    
    return results


def send_email(subject, body):
    ses_client = boto3.client('ses', region_name='eu-south-1')
    
    ses_client.send_email(
        Source=SENDER_EMAIL,
        Destination={'ToAddresses': [RECEIVER_EMAIL]},
        Message={
            'Subject': {'Data': subject},
            'Body': {'Text': {'Data': body}}
        }
    )


def format_email_body(results):
    body = "Job Search Results:\n\n"

    for company, data in results.items():
        body += f"- Company: {company}\n"
        body += f"  URL: {data['url']}\n"
        body += f"  Result: {data['result']}\n"
        body += f"  Number of Days since First Occurrence: {data['count']}\n\n"

    return body
    
    
def lambda_handler(event, context):
    companies = {
        "synapseanalytics" : "https://synapseanalytics.recruitee.com/",
        "espace" : "https://espace.com.eg/jobs/",
        "silicon-mind" : "https://silicon-mind.com/careers/",
        "brightskies" : "https://brightskiesinc.com/careers/jobs"
    }
    
    results = parse_career_pages(companies)
    
    subject = 'DevOps Results'
    body = format_email_body(results)
    
    for company_name, data in results.items():
        if data['result'] == 'yes' and data['count'] <= 3:
            send_email(subject, body)
            break  # Exit the loop after sending the email
        elif data['result'] == 'yes' and data['count'] > 10:
            send_email(subject, body)
            break
    
    response = {
        'statusCode': 200,
        'body': json.dumps(results)
    }
    
    return response