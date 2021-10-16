# Not working without credentials
#output "account_id" {
#  value = data.aws_caller_identity.current.account_id
#}
#
#output "caller_arn" {
#  value = data.aws_caller_identity.current.arn
#}
#
#output "caller_user" {
#  value = data.aws_caller_identity.current.user_id
#}

output "private_ip" {
  value = aws_instance.netology.*.private_ip
}

output "subnet_id" {
  value = aws_instance.netology.*.subnet_id
}