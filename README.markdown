# twitter2vk

## English
Automatic script to repost statuses from Twitter to VK. It also contain in
separated package CLI tool to create config and add cron task.

Warning: config contain session ID for VK, which can be used to get full access.
Make sure that outsiders don’t have access to this file.

By default, reply and statuses with #novk willn’t be reposted to VK.

You may install on server only twitter2vk_reposter package and create config
on home computer (don’t remember to add cron task). Or you can uninstall
twitter2vk after you create config.

### Config
Config is a YAML files with options:

* vk_session – session ID to access to VK.
* twitter – your Twitter login.
* exclude – list of text or regexp patterns to exclude statuses from your VK.
* include – list of text or regexp patterns to repost excluded statuses.
* last_message – file to contain ID of last reposted message.

## Russian

Автоматический скрипт для публикации статусов Twitter’а во В Контакте. Так же
в отдельном пакете есть консольная утилита для создания настроек и добавления
задачи в cron.

Внимание: настройки содержат ID сессии во В Контакте, с помощью которого можно
получить полный доступ. Убедитесь, что посторонние не имеют к файлу доступ.

По умолчанию, ответы и статусы с #novk не будут публиковаться во В Контакте.

Вы можете установить на сервер только пакет twitter2vk_reposter и создать
настройки на домашнем компьютере (не забудьте добавить задание cron). Или можете
удалить пакет twitter2vk, после настройки.

### Настройки
Настройки хранятся в YAML файле с полями:

* vk_session – ID сессии для доступка к В Контакте.
* twitter — логин от вашего Twitter’а.
* exclude — список слов или regexp’ов для статусов, которые не нужно публиковать
  во В Контакте.
* include — список слов или regexp’ов для отмены exclude.
* last_message — файл, чтобы хранить ID последнего полученного сообщения.
