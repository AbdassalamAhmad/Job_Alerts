# Job Alerts
Job Alerts is a repository designed to assist individuals in seeking their ideal job, eliminating the necessity of regularly visiting company websites to check for new available positions.<br><br>

Every day at 8:00 AM, the user will receive an email containing updates on the companies they are interested in working for, notifying them whether these companies have any new job openings or not.

## Project Architecture



## Getting Started
1. Install AWS CLI and configure it with your account credentials. [for more info](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. Install Terraform [Terraform Installaion Page](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. Clone this repo.
4. Install requests library and urllib3==1.25.4 (for compatibility issue)
```sh
mkdir python
cd python
pip install urllib3==1.25.4 requests -t .
```
5. Compress the `python` dir in a `.zip` format with this name `requests_library.zip` in the top directory of the repo.
6. Open `terraform\values.auto.tfvars` file and fill in the values
    - `sender_email`: is the email of the sender (You😄) (you should own it and verify it in SES).
    - `receiver_email`: is the email of the reciever (You too😄) (you should own it and verify it in SES as well).
    - `region`: your closest AWS region.
    - `account_id`: your AWS account id.
    - `job_title`: is the job title you're looking for.
7. open `lambda_function.py` line 99 & 100, add more URLs of the career pages for companies you want to work for.
8. Terraform apply
```sh
cd terraform
terraform apply --auto-aprove  
```
9. Finally, go to your gmail for the sender and receiver email that you set earlier. and verify the identity to make AWS able to send the email from the sender to the reciever on your behalf.<br>
**Note:** I've tried putting the same email for both sender and reciever, and it worked but I got a warnning from gmail, so i used two accounts.
10. Wait at 8:00 AM Cairo-Time (GMT +3) to receive the first email, OR you can go to your AWS lambda `Search_for_Jobs` and do a test from there and you should get an email as well.

## How to Destory AWS Resources
- Simply run `terraform destroy --auto-approve`

## TO-DO List
- [ ] Put the state file in a seperate S3 Bucket.
- [ ] Add tests to Lambda function code.
- [ ] Try to use OOP (any ideas are appreciated).

## Get in Touch
If you have any questions, suggestions, or feedback, please feel free to reach out to me on my [LinkedIn account](https://www.linkedin.com/in/abdassalam-ahmad/).


