# Olga Ivanova, devops-10. Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобится использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы, используемой в ваших проектах.

## Задача 1.
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать отсюда:
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде, и ответы на вопросы станут понятны.

### Ответ
1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на гитхабе.
`resource` - [https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/provider/provider.go#L709](https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/provider/provider.go#L709])
```
		ResourcesMap: map[string]*schema.Resource{
			"aws_accessanalyzer_analyzer": accessanalyzer.ResourceAnalyzer(),
```
   `data_source` - [https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/provider/provider.go#L338](https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/provider/provider.go#L338)
```
		DataSourcesMap: map[string]*schema.Resource{
			"aws_acm_certificate": acm.DataSourceCertificate(),
```

2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`.
   * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
С `name_prefix`: [https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/service/sqs/queue.go#L97](https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/service/sqs/queue.go#L97)
```
		"name": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name_prefix"},
		},
```
   * Какая максимальная длина имени?
   * Какому регулярному выражению должно подчиняться имя?
Длина и регулярное выражение прописаны в `CustomizeDiff` в `resourceQueueCustomizeDiff`. Для FIFO - длина от 1 до 75, заканчивается на `.fifo`; для остальных - от 1 до 80. 
Ссылка - [https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/service/sqs/queue.go#L410](https://github.com/hashicorp/terraform-provider-aws/blob/6076d5a60ec814b243bc45170d67cb268a39d927/internal/service/sqs/queue.go#L410)
Регулярные выражения:  
```
		if fifoQueue {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`)
		} else {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`)
		}
```

## Задача 2. (Необязательно)
В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины.
Также вот официальная документация о создании провайдера:
[https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).

1. Проделайте все шаги создания провайдера.
2. В виде результата приложение ссылку на исходный код.
3. Попробуйте скомпилировать провайдер, если получится, то приложите снимок экрана с командой и результатом компиляции.  