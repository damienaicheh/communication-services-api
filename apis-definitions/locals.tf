locals {
  resource_group_name = data.terraform_remote_state.infra.outputs.resource_group_name
  api_management_name = data.terraform_remote_state.infra.outputs.api_management_name
  func_email_id = data.terraform_remote_state.infra.outputs.func_email_id
  func_email_name = data.terraform_remote_state.infra.outputs.func_email_name
  func_email_default_hostname = data.terraform_remote_state.infra.outputs.func_email_default_hostname
  func_sms_id = data.terraform_remote_state.infra.outputs.func_sms_id
  func_sms_name = data.terraform_remote_state.infra.outputs.func_sms_name
  func_sms_default_hostname = data.terraform_remote_state.infra.outputs.func_sms_default_hostname 
}

