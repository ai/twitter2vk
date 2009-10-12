# twitter2vk

## English
Automatic script to repost statuses from Twitter to VK. It also contain in
separated package CLI tool to create config and add cron task.

Warning: config contain session ID for VK, which can be used to get full access.
Make sure that outsiders don’t have access to this file.

By default, reply and statuses with #novk willn’t be reposted to VK (but you may
use #vk to repost any status).

You may install on server only twitter2vk_reposter package and create config
on home computer (don’t remember to add cron task). Or you can uninstall
twitter2vk after you create config.

You can follow author @andrey_sitnik to receive last updates info.

### Install
1. Install Ruby and Rubygems. For example, on Ubuntu:
   
        sudo apt-get install rubygems
   
2. Install twitter2vk gem:
   
        sudo gem install twitter2vk
   
3. Run master to create config and add crom task:
   
        twitter2vk

### Config
Config is a YAML files with options:

* `vk_session` – session ID to access to VK.
* `twitter` – your Twitter login.
* `exclude` – list of text or regexp patterns to exclude statuses from your VK.
  Code `:reply` will exclude your replies to another Twitter users.
* `include` – list of text or regexp patterns to repost excluded statuses.
* `format` – format reposted status. `%status%` will be replaced by status text,
  `%url%` by status link on Twitter.
* `replace` – list of array with 2 elements to replace text in status. Code
  `:user_to_url` will replace user name to his Twitter link.
* `last_message` – file to contain ID of last reposted message.

## Russian

Автоматический скрипт для публикации статусов Twitter’а во В Контакте. Так же
в отдельном пакете есть консольная утилита для создания настроек и добавления
задачи в cron.

Внимание: настройки содержат ID сессии во В Контакте, с помощью которого можно
получить полный доступ. Убедитесь, что посторонние не имеют к файлу доступ.

По умолчанию, ответы и статусы с #novk не будут публиковаться во В Контакте (но
можно использовать #vk для перепубликации любого статуса).

Вы можете установить на сервер только пакет twitter2vk_reposter и создать
настройки на домашнем компьютере (не забудьте добавить задание cron). Или можете
удалить пакет twitter2vk, после настройки.

Вы можете последовать за автором @andrey_sitnik, чтобы получать информацию
о последних обновлениях.

### Установка
1. Установите Ruby и Rubygems. Например, для Ubuntu:
   
        sudo apt-get install rubygems
   
2. Установите gem twitter2vk:
   
        sudo gem install twitter2vk
   
3. Запустите мастер, чтобы создать настройки и добавить задание к cron:
   
        twitter2vk

### Настройки
Настройки хранятся в YAML файле с полями:

* `vk_session` – ID сессии для доступка к В Контакте.
* `twitter` — логин от вашего Twitter’а.
* `exclude` — список слов или regexp’ов статусов, которые не нужно публиковать
  во В Контакте. Код `:reply` исключ ваши ответы другим пользователя
  Twitter.
* `include` — список слов или regexp’ов для отмены exclude.
* `format` — вид статуса во В Контакте. `%status%` будет заменен на текст
  статуса, `%url%` — на ссылку на статус в Twitter’е.
* `replace` — список массивов из двух элементов для замены текста в статусе. Код
  `:user_to_url` заменит имена пользователей на ссылку на их Twitter.
* `last_message` — файл, чтобы хранить ID последнего полученного сообщения.
