import os
import re
import json
import boto3
from botocore.exceptions import ClientError
from functools import cache


ORG_CLIENT = boto3.client('organizations')
ACCOUNT_CLIENT = boto3.client('account')

ALTERNATE_CONTACTS = {
  'SECURITY': json.loads(os.environ.get('security_alternate_contact')),
  'OPERATIONS': json.loads(os.environ.get('operations_alternate_contact')),
  'BILLING': json.loads(os.environ.get('billing_alternate_contact'))
}
PRIMARY_CONTACT = json.loads(os.environ.get('primary_contact'))

MANAGEMENT_ACCOUNT_ID = os.environ.get('management_account_id')

CONTACT_TAGS = {
  'OPERATIONS': 'tds:contact:operations',
  'SECURITY': 'tds:contact:security'
}

DEFAULT_CONTACT_EMAIL = 'support@basefarm-orange.com'

FAILED_ACCOUNTS = []

def list_accounts(client):
  response = client.list_accounts()
  accounts = []
  while response:
    accounts += response['Accounts']
    if "NextToken" in response:
      response = client.list_accounts(NextToken = response['NextToken'])
    else:
      response = None
  return accounts

@cache
def list_parents(client, ChildId):
  return client.list_parents( ChildId=ChildId)

@cache
def list_tags_for_resource(client, ResourceId):
  tags = {}
  response = client.list_tags_for_resource( ResourceId = ResourceId )
  if 'Tags' in response:
    tags = {t['Key']: t['Value'] for t in response['Tags']}
  return tags

def get_ous(client, account_id):
  parent_list = [ account_id ]
  response = list_parents(client, ChildId=account_id )
  while response['Parents'][0]['Type'] != 'ROOT':
    parent_list.append(response['Parents'][0]['Id'])
    response = list_parents(client, ChildId=response['Parents'][0]['Id'])
  parent_list.append(response['Parents'][0]['Id'])
  parent_list.reverse()
  return parent_list

def get_tag_contacts(client, resources):
  contacts = {
    'SECURITY': DEFAULT_CONTACT_EMAIL,
    'OPERATIONS': DEFAULT_CONTACT_EMAIL
  }
  for ResourceId in resources:
    tags = list_tags_for_resource(client, ResourceId )
    for tag in tags:
      for key, value in CONTACT_TAGS.items():
        if tag.startswith(value):
          contacts[key] = tags[tag]
  return contacts

def get_contacts(client, account_id):
  return get_tag_contacts(client, get_ous(client, account_id))

# Full name is a mandatory parameter and is uniq to every account
def get_full_name(accountId):
  try:
    if accountId != MANAGEMENT_ACCOUNT_ID:
      response = ACCOUNT_CLIENT.get_contact_information(AccountId=accountId)
    else:
      response = ACCOUNT_CLIENT.get_contact_information()
    return response["ContactInformation"]["FullName"]
  except ClientError as error:
    FAILED_ACCOUNTS.append(accountId)
    raise error  # Need to abort, do not want to continue with missing account name

def update_alternate_contact(accountId):
  optional_contacts = get_contacts(ORG_CLIENT, accountId)

  for type, contact in ALTERNATE_CONTACTS.items():
    try:
      account_contact = contact.copy()
      if type in optional_contacts:
        if optional_contacts[type] == '':
          delete_params = {
            'AlternateContactType': type
          }
          if accountId != MANAGEMENT_ACCOUNT_ID:
            delete_params['AccountId'] = accountId
          print("Delete alternate contact ", type)
          try:
            ACCOUNT_CLIENT.delete_alternate_contact(**delete_params)
          except ClientError as error:
            if error.response['Error']['Code'] == 'ResourceNotFoundException':
              pass
            else:
              raise error
            pass
          continue
        else:
          account_contact['EmailAddress'] = optional_contacts[type]
      if accountId != MANAGEMENT_ACCOUNT_ID:
        account_contact['AccountId'] = accountId
      print("Setting alternate contact ", type, "to ", account_contact)
      ACCOUNT_CLIENT.put_alternate_contact(**account_contact)
    except ClientError as error:
      FAILED_ACCOUNTS.append(accountId)
      print(error)
      pass

def update_primary_contact(accountId):
  try:
    contact = PRIMARY_CONTACT.copy()
    contact["FullName"] = get_full_name(accountId)
    print("Setting primary contact to ", contact)
    if accountId != MANAGEMENT_ACCOUNT_ID:
      ACCOUNT_CLIENT.put_contact_information(
        AccountId = accountId,
        ContactInformation=contact)
    else:
      ACCOUNT_CLIENT.put_contact_information(ContactInformation=contact)
  except ClientError as error:
    FAILED_ACCOUNTS.append(accountId)
    print(error)
    pass

def lambda_handler(event, context):
  for account in list_accounts(ORG_CLIENT):
    if account["Status"] != "SUSPENDED":
      print("Updating contact information for ", account["Id"])
      update_primary_contact(account["Id"])
      update_alternate_contact(account["Id"])
  return (FAILED_ACCOUNTS)
