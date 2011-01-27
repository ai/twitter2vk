# twitter2vk

## По-русски

Скрипт для автоматической публикации статусов Twitter’а во В Контакте. Так же
в отдельном пакете есть консольная утилита для создания настроек и добавления
задачи в cron.

Внимание: настройки содержат ID сессии во В Контакте, с помощью которого можно
получить полный доступ. Убедитесь, что посторонние не имеют к файлу доступ.

По умолчанию, ответы и статусы с #novk не будут публиковаться во В Контакте (но
можно использовать #vk для перепубликации любого статуса).

Вы можете установить на сервер только пакет twitter2vk_reposter и создать
настройки на домашнем компьютере (не забудьте добавить задание cron). Или можете
удалить пакет twitter2vk, после настройки.

Вы можете последовать за автором
[@andrey_sitnik](http://twitter.com/andrey_sitnik), чтобы получать информацию о
последних обновлениях. По всем вопросам можно писать на <andrey@sitnik.ru>.

Подробная статья — <http://habrahabr.ru/blogs/twitter/88386/>.

### Возможности
- Не хранит пароли в настройках.
- Поддерживает ретвиты.
- Имеет гибкие настройки формата статуса и игнорирования статусов.

### Установка
1. Установите Ruby и Rubygems. Например, для Ubuntu:
   
        sudo apt-get install rubygems build-essential
   
2. Установите gem twitter2vk:
   
        sudo gem install twitter2vk
   
3. Запустите мастер, чтобы создать настройки и добавить задание к cron:
   
        twitter2vk

### Настройки
Настройки хранятся в YAML файле с полями:

* `vk_session` – ID сессии для доступка к В Контакте.
* `twitter_token`, `twitter_secret` — данные для доступа к Twitter’у через
  OAuth.
* `exclude` — список слов или regexp’ов статусов, которые не нужно публиковать
  во В Контакте. Код `:reply` исключит ваши ответы другим пользователя,
  `:retweet` — ретвиты от вас, `:all` — все сообщения (имеет смысл, если
  комбинировать с правилами из `include`).
* `include` — список слов или regexp’ов для отмены exclude.
* `format` — вид статуса во В Контакте. `%status%` будет заменён на текст
  статуса, `%url%` — на ссылку на статус в Twitter’е.
* `last` — текст после `format`. Если статус больше допустимого во В Контакте,
  то первым делом обрезается `format`, поэтому `last` удобен для указания ссылки
  на твит.
* `retweet` — вид ретвита. `%status%` будет заменён на текст, `%author%` — на
  автора твита.
* `replace` — список массивов из двух элементов для замены текста в статусе. Код
  `:user_to_url` заменит имена пользователей на ссылку на их Twitter.
* `last_message` — файл, чтобы хранить ID последнего полученного сообщения.

## English
Script to automatically repost statuses from Twitter to VK. It also contain in
separated package CLI tool to create config and add cron task.

Warning: config contain session ID for VK, which can be used to get full access.
Make sure that outsiders don’t have access to this file.

By default, reply and statuses with #novk willn’t be reposted to VK (but you may
use #vk to repost any status).

You may install on server only twitter2vk_reposter package and create config
on home computer (don’t remember to add cron task). Or you can uninstall
twitter2vk after you create config.

You can follow author [@andrey_sitnik](http://twitter.com/andrey_sitnik)
to receive last updates info. You can ask me any questions by e-mail:
<andrey@sitnik.ru>.

### Features
* Don’t store passwords in config.
* Retweet support.
* Flexible status format and ignore rules.

### Install
1. Install Ruby and Rubygems. For example, on Ubuntu:
   
        sudo apt-get install rubygems build-essential
   
2. Install twitter2vk gem:
   
        sudo gem install twitter2vk
   
3. Run master to create config and add crom task:
   
        twitter2vk

### Config
Config is a YAML files with options:

* `vk_session` – session ID to access to VK.
* `twitter_token`, `twitter_secret` — data to access to Twitter by OAuth.
* `exclude` – list of text or regexp patterns to exclude statuses from your VK.
  Code `:reply` will exclude your replies to another users, `:retweet` will
  exclude retweets by you, `:all` will exclude all message (make sense with
  `include` rules).
* `include` – list of text or regexp patterns to repost excluded statuses.
* `format` – format reposted status. `%status%` will be replaced by status text,
  `%url%` by status link on Twitter.
* `last` — text after `format`. If status will be longer that VK allow,
  `format` will be trim first. So `last` it useful, to set link to Twitter
  status.
* `retweet` — format of retweet. `%status%` will be replaced by text,
  `%author%` will be replace by tweet author.
* `replace` – list of array with 2 elements to replace text in status. Code
  `:user_to_url` will replace user name to his Twitter link.
* `last_message` – file to contain ID of last reposted message.
