# devops-netology

## Olga Ivanova, devops-10

## .gitignore в terraform:
1. **/.terraform/* - вложенные директории (**) с названием .terraform
2. *.tfstate - файлы .tfstate с любым количеством символов до .tfstate
3. *.tfstate.* - файлы .tfstate с любым количеством символов до .tfstate и после
4. crash.log - файлы crash.log
5. *.tfvars - файлы .tfvars с любым количеством символов до .tfvars
6. файлы override.tf:
override.tf - с совпадающим названием
override.tf.json - с совпадающим названием
*_override.tf - с любым количеством символов до _
*_override.tf.json - с любым количеством символов до _
7. .terraformrc - файлы с совпадающим названием
8. terraform.rc - файлы с совпадающим названием
