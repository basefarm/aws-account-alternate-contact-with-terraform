import os
import re
import json
import boto3
from botocore.exceptions import ClientError

ORG_CLIENT = boto3.client("organizations")
ACCOUNT_CLIENT = boto3.client("account")

SEC_ALTERNATE_CONTACTS = os.environ.get("security_alternate_contact")
BILL_ALTERNATE_CONTACTS = os.environ.get("operations_alternate_contact")
OPS_ALTERNATE_CONTACTS = os.environ.get("billing_alternate_contact")
MANAGEMENT_ACCOUNT_ID = os.environ.get("management_account_id")
PRIMARY_CONTACT = json.loads(os.environ.get("primary_contact"))

CONTACTS = []
FAILED_ACCOUNTS = []

def list_accounts(client):
    response = client.list_accounts()
    accounts = []
    while response:
        accounts += response["Accounts"]
        if "NextToken" in response:
            response = client.list_accounts(NextToken = response["NextToken"])
        else:
            response = None
    return accounts

def parse_contact_types():
    CONTACT_LIST = []
    for contact in [SEC_ALTERNATE_CONTACTS, BILL_ALTERNATE_CONTACTS, OPS_ALTERNATE_CONTACTS]:
        CONTACT_LIST = re.split("=|; ", contact)
        list_to_dict = {CONTACT_LIST[i]: CONTACT_LIST[i + 1] for i in range(0, len(CONTACT_LIST), 2)}
        CONTACTS.append(list_to_dict)

def put_alternate_contact(accountId):
    for contact in CONTACTS:
        try:
            if accountId != MANAGEMENT_ACCOUNT_ID:
                response = ACCOUNT_CLIENT.put_alternate_contact(
                    AccountId=accountId,
                    AlternateContactType=contact["CONTACT_TYPE"],
                    EmailAddress=contact["EMAIL_ADDRESS"],
                    Name=contact["CONTACT_NAME"],
                    PhoneNumber=contact["PHONE_NUMBER"],
                    Title=contact["CONTACT_TITLE"],
                )
            else:
                response = ACCOUNT_CLIENT.put_alternate_contact(
                    AlternateContactType=contact["CONTACT_TYPE"],
                    EmailAddress=contact["EMAIL_ADDRESS"],
                    Name=contact["CONTACT_NAME"],
                    PhoneNumber=contact["PHONE_NUMBER"],
                    Title=contact["CONTACT_TITLE"],
                )
        except ClientError as error:
            FAILED_ACCOUNTS.append(accountId)
            print(error)
            pass

# Full name is a mandatory parameter and is uniq to every account
def get_full_name(accountId):
  try:
      if accountId != MANAGEMENT_ACCOUNT_ID:
          response = ACCOUNT_CLIENT.get_contact_information(
              AccountId=accountId
          )
      else:
          response = ACCOUNT_CLIENT.get_contact_information()

      return response["ContactInformation"]["FullName"]
  except ClientError as error:
      FAILED_ACCOUNTS.append(accountId)
      print(error)
      pass
      return None

def update_primary_contact(accountId):
    try:
        contact = PRIMARY_CONTACT.copy()
        contact["FullName"] = get_full_name(accountId)
        if accountId != MANAGEMENT_ACCOUNT_ID:
            response = ACCOUNT_CLIENT.put_contact_information(
                AccountId = accountId,
                ContactInformation=contact
            )
        else:
            response = ACCOUNT_CLIENT.put_contact_information(
                ContactInformation=contact
            )
    except ClientError as error:
      FAILED_ACCOUNTS.append(accountId)
      print(error)
      pass

def lambda_handler(event, context):
    parse_contact_types()
    for account in list_accounts(ORG_CLIENT):
        if account["Status"] != "SUSPENDED":
            print("Updating contact information for ", account["Id"])
            put_alternate_contact(account["Id"])
            update_primary_contact(account["Id"])

#    put_alternate_contact_master()
#    update_primary_contact(MANAGEMENT_ACCOUNT_ID)

    return (FAILED_ACCOUNTS)
