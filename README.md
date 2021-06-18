# devops-netology

## Olga Ivanova, devops-10

## 02-git-01-vcs .gitignore в terraform:
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

## 02-git-02-base Задание 4

## 02-git-04-tools
1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.

Команда: `git show aefea --format="Hash=%H Comment=%s" -s`, где -s означает игнорирование вывода diff, 
--format - вывод только необходимой нам информации.   
Для хеша можно также использовать: `git rev-parse aefea`

Результат:  
Хеш: aefead2207ef7e2aa5dc81a34aedf0cad4c32545  
Комментарий: Update CHANGELOG.md

2. Какому тегу соответствует коммит `85024d3`?  

Команда: `git tag --points-at 85024d3`  
Результат: v0.12.23
   
3. Сколько родителей у коммита `b8d720`? Напишите их хеши.
   
Команды:  
`git show b8d720^ --pretty=tformat:"%H" -s`  
`git show b8d720^2 --pretty=tformat:"%H" -s`

Это merge-коммит, поэтому у него 2 предка.
Их хэши:  
56cd7859e05c36c06b56d013b55a252d0bb7e158  
9ea88f22fc6269854151c571162c5bcf958bee2b  

4. Перечислите хеши и комментарии всех коммитов, которые были сделаны между тегами  v0.12.23 и v0.12.24.
   
Возможные команды:  
`git log v0.12.23..v0.12.24 --format="Hash=%H Comment=%s" -s` или  
`git log ^v0.12.23 v0.12.24 --format="Hash=%H Comment=%s" -s` или  
`git log v0.12.24 --not v0.12.23 --format="Hash=%H Comment=%s" -s`  
Вместо --format можно использовать, например, --oneline

Результат:

Hash=33ff1c03bb960b332be3af2e333462dde88b279e Comment=v0.12.24  
Hash=b14b74c4939dcab573326f4e3ee2a62e23e12f89 Comment=[Website] vmc provider links  
Hash=3f235065b9347a758efadc92295b540ee0a5e26e Comment=Update CHANGELOG.md  
Hash=6ae64e247b332925b872447e9ce869657281c2bf Comment=registry: Fix panic when server is unreachable  
Hash=5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 Comment=website: Remove links to the getting started guide's old location  
Hash=06275647e2b53d97d4f0a19a0fec11f6d69820b5 Comment=Update CHANGELOG.md  
Hash=d5f9411f5108260320064349b757f55c09bc4b80 Comment=command: Fix bug when using terraform login on Windows  
Hash=4b6d06cc5dcb78af637bbb19c198faff37a066ed Comment=Update CHANGELOG.md  
Hash=dd01a35078f040ca984cdd349f18d0b67e486c35 Comment=Update CHANGELOG.md  
Hash=225466bc3e5f35baa5d07197bbc079345b77525e Comment=Cleanup after v0.12.23 release

5. Найдите коммит, в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточего перечислены аргументы).

Возможные команды:  
`git log -S "func providerSource" --oneline` или  
`git log -G "func providerSource\(.*\)" --oneline`  

Результат:  
5af1e6234 main: Honor explicit provider_installation CLI config when present  
8c928e835 main: Consult local directories as potential mirrors of providers

В этих коммитах было создание, изменение или удаление функции. Если сделать `git show 8c928e835`, то увидим,
что функция была создана в этом коммите.  
Поэтому итоговый ответ: 8c928e835 main: Consult local directories as potential mirrors of providers

6. Найдите все коммиты, в которых была изменена функция `globalPluginDirs`.
   
Команды:  
`git grep -n globalPluginDirs` - находим строки, где встречается данная функция. Видим, что функция определена в файле plugins.go.  
`git log -L :globalPluginDirs:plugins.go` - находим изменения содержимого функции.  

Результат:  
commit 78b12205587fe839f10d946ea3fdc06719decb05  
commit 52dbf94834cb970b510f2fba853a5b49ad9b1a46  
commit 41ab0aef7a0fe030e84018973a64135b11abcd70  
commit 66ebff90cdfaa6938f26f908c7ebad8d547fea17  
commit 8364383c359a6b738a436d1b7745ccdce178df47  

   
7. Кто автор функции `synchronizedWriters`?

Команда:
`git log -S "synchronizedWriters" --pretty=short` - находим коммиты, где была создана/изменена/удалена функция. 

Находим (`git show 5ac311e2a91e381e2f52234668b49ba670aa0fe5`), что функция была определена в коммите:
commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5
Author: Martin Atkins <mart@degeneration.co.uk>
