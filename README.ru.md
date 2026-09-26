# dotfiles

[English](README.md) | [Русский](README.ru.md)

Мои дотфайлы для Windows — личный сетап в духе i3.

Цель — **управляемый с клавиатуры, тайлинговый рабочий стол без мыши** на
Windows: GlazeWM берёт на себя тайлинговый менеджер окон, Zebar заменяет
панель задач на настраиваемую панель состояния, а Emacs — редактор. В этом
репозитории лежат конфиги всех трёх и небольшой Lua-скрипт, который
раскладывает их по нужным местам на машине.

## Что здесь настроено

| Область | Инструмент | Куда разворачивается |
| --- | --- | --- |
| Управление окнами | [GlazeWM](https://github.com/glzr-io/glazewm) | `%USERPROFILE%\.glzr\glazewm\` |
| Панель состояния | [Zebar](https://github.com/glzr-io/zebar) | `%USERPROFILE%\.glzr\zebar\` |
| Редактор | Emacs | `%USERPROFILE%\.emacs`, `.emacs.rc\`, `.emacs.local\`, `.emacs.snippets\` |
| Прочее | git, emacs custom-файл | `%USERPROFILE%\.gitconfig`, `.gitignore`, `.emacs.custom.el` |

Вышедшие из употребления конфиги (старый сетап i3, mpv, tmux, Xresources и
прочее) лежат в `old/` и сохраняются для справки, а не удаляются.

## Соглашение

Каждый элемент этого репозитория лежит по **тому же относительному пути,
который он занимает в `%USERPROFILE%`**. На этом и построен `deploy.lua`: он
вызывает PowerShell `Copy-Item` и кладёт каждый указанный путь прямо в
`%USERPROFILE%`, так что путь в репозитории *и есть* путь назначения:

```
dotfiles\.glzr\glazewm\config.yaml   ->   %USERPROFILE%\.glzr\glazewm\config.yaml
dotfiles\.emacs                      ->   %USERPROFILE%\.emacs
```

Так всё остаётся предсказуемым: никаких таблиц соответствий, шаблонов и
символических ссылок. Что читаешь в репозитории — то и лежит на машине.

Исключение — `old/`, он не разворачивается вообще.

## Структура

```
deploy.lua            деплойер (Lua 5.5; lua55.exe лежит рядом)
WINDOWS_CONFIGS       список путей, копируемых в %USERPROFILE%
old/                  старые конфиги, для ветки очистки -f
.glzr/                GlazeWM + Zebar
  glazewm/config.yaml
  zebar/settings.json
  zebar/my-bar/       собственный пакет виджетов Zebar
.emacs                основной конфиг Emacs
.emacs.rc/            вынесенные модули конфига
.emacs.local/         личный elisp, привязанный к машине
.emacs.snippets/      сниппеты Yasnippet
```

`*.swp`, `*.swo` и `errors.log` в gitignore — это мусор редактора и рантайма,
а не конфигурация.

## Деплой

```sh
lua55.exe deploy.lua          # разложить всё в %USERPROFILE%
lua55.exe deploy.lua -h       # помощь
```

`Copy-Item -Recurse` **сливается** с уже существующим каталогом назначения, а
не вкладывается в него, поэтому повторный запуск безопасен — он не создаст
`~\.glzr\.glzr`.

### Два известных бага в `deploy.lua`

Оба появились до работы с Zebar и были найдены при документировании скрипта.
Ни один пока не исправлен.

**1. Любой аргумент молча отменяет деплой.** `pushFiles()` вызывается из
`if (#arg < 1)`, но внутри цикла по аргументам она достигается только через
`-f`. Поэтому `-d` и любой нераспознанный флаг не делают вообще ничего — а
поскольку `-f` делает `return` раньше остальных, единственный порядок, при
котором вообще видно отладочный вывод, — это `-d -f`. Точку входа нужно
переписать в нормальную цепочку `if/elseif` по флагам с одним
безусловным деплоем в конце.

**2. `-f` не удаляет ничего.** `deleteFiles()` разбивает список файлов по
буквальному пробелу, но `Out-String` в PowerShell разделяет имена переводами
строк, так что весь `old/` схлопывается в *один* токен с зашитыми внутрь
переводами строк:

```
token count = 1
token 1 = [.apvlvrc
.gdbinit
.ghci
...
```

Получается один бессмысленный путь вида
`C:\Users\ivan\.apvlvrc\n.gdbinit\n...`, на котором `Remove-Item` падает — и
молча, потому что вызов проходит с `-ErrorAction SilentlyContinue`. Фикс —
разбивать по пробельным символам (`"%s+"`) вместо `" "`, а на стороне
PowerShell добавить `-split` по `\r?\n`.

Считай `-f` пока просто «раскладыванием», пока это не исправят.

---

# GlazeWM

Тайлинговый менеджер окон для Windows.

- **Апстрим:** <https://github.com/glzr-io/glazewm>
- **Документация:** <https://glazewm.com/>
- **Установленная версия:** 3.10.1
- **Путь установки:** `C:\Program Files\glzr.io\GlazeWM\`

| Файл | Назначение |
| --- | --- |
| `glazewm.exe` | сам менеджер окон |
| `glazewm-watcher.exe` | поднимает WM после перезапуска проводника |
| `cli\glazewm.exe` | CLI `glazewm`, уже в `PATH` |

### Конфиг

`%USERPROFILE%\.glzr\glazewm\config.yaml` — отслеживается как
`.glzr/glazewm/config.yaml`.

Один YAML-файл, ~274 строки, секции: `general`, `gaps`, `window_effects`,
`window_behavior`, `workspaces`, `window_rules`, `binding_modes`, `keybindings`.
Основную часть составляют хоткеи; проще открыть файл, чем дублировать его
здесь.

Zebar берёт состояние GlazeWM через собственный провайдер `glazewm`, так что
панель отражает воркспейсы, направление тайлинга, режимы привязки и
состояние паузы без всякой дополнительной обвязки.

# Zebar

Настраиваемая панель для Windows и Linux, построенная на нативных вебвью.
Здесь используется как панель состояния для GlazeWM.

- **Апстрим:** <https://github.com/glzr-io/zebar>
- **Discord:** <https://discord.gg/ud6z3qjRvM>
- **Путь установки:** `C:\Program Files\glzr.io\Zebar\zebar.exe`
- **Зафиксированная схема:** `v3.1.1` (поле `$schema` в `settings.json`)

## Где лежит конфиг

Единого конфигурационного файла нет; важны три места.

| Путь | Содержимое |
| --- | --- |
| `%USERPROFILE%\.glzr\zebar\settings.json` | какой виджет запускать |
| `%USERPROFILE%\.glzr\zebar\<pack>\zpack.json` | **твои пакеты виджетов** |
| `%AppData%\zebar\downloads\<pack>@<ver>\` | скачанные пакеты маркетплейса |

Всё внутри `%USERPROFILE%\.glzr\` отслеживается здесь. Дерево
`%AppData%\zebar\` (`downloads\`, `webview-cache\`, `.migrations.json`) —
генерируемое состояние, и оно намеренно **не** отслеживается.

## Как устроены пакеты виджетов

*Пакет* — это каталог прямо внутри `.glzr\zebar\`, содержащий `zpack.json`.
В пакете может быть несколько *виджетов*; каждый виджет — это вебвью с
HTML-файлом и ассетами.

```
.glzr/zebar/my-bar/         <- каталог пакета, на уровень ниже .glzr/zebar
  zpack.json                <- определения пакета и виджетов
  with-glazewm.html         <- виджет, запускаемый при старте
  vanilla.html
  with-komorebi.html
  styles.css
```

### Подводный камень: ID пакета — это поле `name`, а не имя папки

Об этом стоит знать, потому что формулировка в апстримном README провоцирует
ошибку. В `widget_pack.rs`:

```rust
id: match metadata {
  Some(metadata) => metadata.pack_id.clone(),
  None => pack_config.name.to_string(),   // свои пакеты берут ID из "name"
},
```

ID собственного пакета — это значение `"name"` **внутри** `zpack.json`.
Переименование папки ничего не даёт; переименование этого поля — даёт.
`startupConfigs[].pack` в `settings.json` должен совпадать с ним, иначе на
старте будет:

```
ERROR zebar::widget_factory: Failed to start widget on startup:
No widget pack found for '<id>'.
```

Исключение — пакеты маркетплейса: их ID берётся из `packId` маркетплейса.

### Никогда не правь пакет из маркетплейса на месте

Каталог `%AppData%\zebar\downloads\` перезаписывается при каждом обновлении
пакета. Скопируй каталог пакета в `%USERPROFILE%\.glzr\zebar\`, дай ему
собственный `name` в `zpack.json` и укажи его в `settings.json`.

Именно так и устроен `my-bar`: это форк `glzr-io.starter`.

## Текущая конфигурация

`settings.json` запускает `my-bar` / `with-glazewm` — привязка к левому
верхнему углу, 100% ширины, 40px высоты, на всех мониторах, без стыковки к
краю, то есть панель лежит поверх окон, а не резервирует место.

`my-bar` отличается от апстримного `glzr-io.starter` в двух вещах:

- **Принудительная тёмная тема.** Апстрим выбирает палитру через
  `@media (prefers-color-scheme: ...)`, то есть панель следует за *темой
  приложений* в Windows. На этой машине включён светлый режим для приложений
  при тёмной панели задач, из-за чего панель поднималась светлой. Теперь в
  `styles.css` тёмная палитра применяется безусловно, плюс выставлен
  `color-scheme: dark`. Чтобы вернуть следование за ОС, достаточно вернуть
  два медиазапроса.
- **Без погоды.** Провайдер `weather`, его хелпер `getWeatherIcon` и блок
  отрисовки удалены из `with-glazewm.html`. В `vanilla.html` и
  `with-komorebi.html` они остались, но эти виджеты не используются.

На панели слева направо: логотип, воркспейсы GlazeWM, дата, режимы привязки,
направление тайлинга, сеть, память, CPU, батарея.

## Автозапуск

Ни GlazeWM, ни Zebar сейчас не стартуют автоматически — нет записи в
`HKCU\...\Run`, нет запланированной задачи, ничего в папке автозагрузки.

Для Zebar это делается через GUI: иконка в трее -> `Widget packs` -> `<pack>`
-> `<widget>` -> `Run on startup`. Это эквивалентно сохранению записи
`startupConfigs` в `settings.json`. Для GlazeWM — запускай
`glazewm-watcher.exe` при входе.

## Провайдеры

Системные данные попадают в виджеты как реактивные *провайдеры* из npm-пакета
`zebar`, объявленные группой:

```js
const providers = zebar.createProviderGroup({
  network: { type: 'network' },
  glazewm: { type: 'glazewm' },
  cpu:     { type: 'cpu' },
  date:    { type: 'date', formatting: 'EEE d MMM t' },
  battery: { type: 'battery' },
  memory:  { type: 'memory' },
});
```

Доступны: `audio`, `battery`, `cpu`, `date`, `disk`, `glazewm`, `host`, `ip`,
`keyboard`, `komorebi`, `media`, `memory`, `network`, `systray`, `weather`.
Значения читаются из `providers.outputMap`, перерисовка — в
`providers.onOutput(...)`.

Большинство виджетов **без сборки** — React выполняется прямо в вебвью с CDN
через тег `text/babel`, так что шага сборки нет. Шаблонам Solid/TS уже нужен
Node и `pnpm build` после правок.

## Отладка

**Сначала смотри лог:** `%USERPROFILE%\.glzr\zebar\errors.log`. Пустой файл
означает чистый старт. Удали его перед перезапуском, чтобы получить свежий
сигнал.

**После правки пакета перезапусти Zebar.** Поиск пакетов происходит один раз
при старте. `WidgetPackManager::reload()` в исходниках есть, но не выставлен
как Tauri-команда, то есть вызвать его нечем — запущенный инстанс не заметит
ни нового каталога пакета, ни изменения в `zpack.json`.

**Zebar не стартует на Windows.** Обычно виноват устаревший рантайм WebView2.
Поставь Evergreen Standalone Installer от администратора:
<https://developer.microsoft.com/en-us/microsoft-edge/webview2/>

## С нуля на новой машине

1. Поставь GlazeWM, затем Zebar, затем Emacs.
2. Склонируй этот репозиторий в `%USERPROFILE%\dotfiles`.
3. Выполни `lua55.exe deploy.lua`, чтобы разложить конфиги.
4. Запусти Zebar один раз, чтобы он подтянул вебвью-рантайм.
5. В GUI Zebar проверь, что `my-bar` / `with-glazewm` — стартовый виджет.
