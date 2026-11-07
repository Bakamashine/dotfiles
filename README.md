# dotfiles

[English](README.md) | [Русский](README.ru.md)

My Windows dotfiles — a personal i3-style setup.

The goal is a **keyboard-driven, tiling, mouse-free desktop** on Windows:
GlazeWM supplies the tiling window manager, Zebar replaces the taskbar with a
configurable status bar, and Emacs is the editor. This repo holds the configs
for all three and a small PowerShell script that deploys them to the right
places on the machine.

## What is managed here

| Area | Tool | Deployed to |
| --- | --- | --- |
| Window management | [GlazeWM](https://github.com/glzr-io/glazewm) | `%USERPROFILE%\.glzr\glazewm\` |
| Status bar | [Zebar](https://github.com/glzr-io/zebar) | `%USERPROFILE%\.glzr\zebar\` |
| Editor | Emacs | `%USERPROFILE%\.emacs`, `.emacs.rc\`, `.emacs.local\`, `.emacs.snippets\` |
| Shell/misc | git, emacs custom file | `%USERPROFILE%\.gitconfig`, `.gitignore`, `.emacs.custom.el` |

Retired configs (my old i3 setup, mpv, tmux, Xresources, etc.) live in `old/`
and are kept for reference rather than deleted.

## The convention

Every entry in this repo sits at the **same relative path it occupies in
`%USERPROFILE%`**. `deploy.ps1` depends on this — it uses `Copy-Item` to drop
each configured path straight into `%USERPROFILE%`, so the repo path *is* the
destination path:

```
dotfiles\.glzr\glazewm\config.yaml   ->   %USERPROFILE%\.glzr\glazewm\config.yaml
dotfiles\.emacs                      ->   %USERPROFILE%\.emacs
```

This keeps things predictable: no mapping table, no templates, no symlinks.
What you read in the repo is what is on the machine.

`old/` is the exception, and is not deployed at all.

## Layout

```
deploy.ps1            the deployer (PowerShell)
WindowsConfigs        the list of paths copied to %USERPROFILE%
old/                  retired configs, for the -f cleanup path
.glzr/                GlazeWM + Zebar
  glazewm/config.yaml
  zebar/settings.json
  zebar/my-bar/       custom Zebar widget pack
.emacs                main Emacs config
.emacs.rc/            split-off config modules
.emacs.local/         personal elisp, machine-specific
.emacs.snippets/      Yasnippet snippets
```

`*.swp`, `*.swo` and `errors.log` are gitignored — editor and runtime
droppings, not configuration.

## Deploying

```powershell
.\deploy.ps1          # push everything to %USERPROFILE%
.\deploy.ps1 -h       # help
```

If PowerShell blocks the script because of the execution policy, run it with:

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1
```

`Copy-Item -Recurse` **merges** into an existing destination rather than
nesting, so running the deploy repeatedly is safe — it will not create
`~\.glzr\.glzr`.

### Deploy notes

- If a destination is a symlink or junction (for example left over from an old
  repo location), `deploy.ps1` removes the link itself before copying. A
  dangling link would otherwise make `Copy-Item` fail.
- `-d` adds debug output and still deploys.
- `-f` removes the entries listed in `old/` from `%USERPROFILE%` and
  `%APPDATA%`, then deploys.
- `-cl` only removes those old entries.
- `-glzr` also deploys `.glzr` (GlazeWM + Zebar).

---

# GlazeWM

Tiling window manager for Windows.

- **Upstream:** <https://github.com/glzr-io/glazewm>
- **Docs:** <https://glazewm.com/>
- **Version installed:** 3.10.1
- **Install path:** `C:\Program Files\glzr.io\GlazeWM\`

| File | Purpose |
| --- | --- |
| `glazewm.exe` | the window manager |
| `glazewm-watcher.exe` | keeps the WM alive across explorer restarts |
| `cli\glazewm.exe` | `glazewm` CLI, already on `PATH` |

### Config

`%USERPROFILE%\.glzr\glazewm\config.yaml` — tracked as
`.glzr/glazewm/config.yaml`.

One YAML file, ~274 lines, sections: `general`, `gaps`, `window_effects`,
`window_behavior`, `workspaces`, `window_rules`, `binding_modes`, `keybindings`.
The keybindings are the bulk of it; read the file rather than duplicating it
here.

Zebar picks GlazeWM state up through its own `glazewm` provider, so the bar
reflects workspaces, tiling direction, binding modes and the paused state with
no extra glue.

# Zebar

Configurable desktop bar for Windows and Linux, built on native webviews.
Used here as the GlazeWM status bar.

- **Upstream:** <https://github.com/glzr-io/zebar>
- **Discord:** <https://discord.gg/ud6z3qjRvM>
- **Install path:** `C:\Program Files\glzr.io\Zebar\zebar.exe`
- **Schema pinned:** `v3.1.1` (the `$schema` field in `settings.json`)

## Where the config lives

There is no single config file; three locations matter.

| Path | Contents |
| --- | --- |
| `%USERPROFILE%\.glzr\zebar\settings.json` | which widget to start |
| `%USERPROFILE%\.glzr\zebar\<pack>\zpack.json` | **your widget packs** |
| `%AppData%\zebar\downloads\<pack>@<ver>\` | marketplace downloads |

Everything under `%USERPROFILE%\.glzr\` is tracked here. The `%AppData%\zebar\`
tree (`downloads\`, `webview-cache\`, `.migrations.json`) is generated state and
is deliberately **not** tracked.

## How widget packs work

A *pack* is a directory directly under `.glzr\zebar\` containing a
`zpack.json`. A pack holds several *widgets*; each widget is a webview entry
point of HTML plus assets.

```
.glzr/zebar/my-bar/         <- pack dir, one level under .glzr/zebar
  zpack.json                <- pack and widget definitions
  with-glazewm.html         <- the widget started on boot
  vanilla.html
  with-komorebi.html
  styles.css
```

### Gotcha: the pack ID is the `name` field, not the folder name

This is worth knowing, because the upstream README's wording invites the
mistake. In `widget_pack.rs`:

```rust
id: match metadata {
  Some(metadata) => metadata.pack_id.clone(),
  None => pack_config.name.to_string(),   // custom packs use the JSON "name"
},
```

A custom pack's ID is the `"name"` value **inside** `zpack.json`. Renaming the
folder does nothing; renaming that field does. `startupConfigs[].pack` in
`settings.json` must match it, or startup fails with:

```
ERROR zebar::widget_factory: Failed to start widget on startup:
No widget pack found for '<id>'.
```

Marketplace packs are the exception — their ID is the marketplace `packId`.

### Never edit a marketplace pack in place

`%AppData%\zebar\downloads\` is overwritten whenever the pack updates. Copy the
pack directory into `%USERPROFILE%\.glzr\zebar\`, give it a distinct `name` in
`zpack.json`, and point `settings.json` at it.

That is exactly what `my-bar` is: a fork of `glzr-io.starter`.

## Current setup

`settings.json` starts `my-bar` / `with-glazewm` — anchored top-left, 100% wide,
40px tall, on all monitors, not docked, so it overlays rather than reserving
screen space.

`my-bar` differs from upstream `glzr-io.starter` in two ways:

- **Forced dark.** Upstream picks its palette from
  `@media (prefers-color-scheme: ...)`, so the bar follows the Windows *app*
  theme. This machine is light-for-apps / dark-taskbar, which made the bar come
  up light. `styles.css` now applies the dark palette unconditionally and sets
  `color-scheme: dark`. To go back to following the OS, restore the two media
  query blocks.
- **No weather.** The `weather` provider, its `getWeatherIcon` helper and its
  render block were removed from `with-glazewm.html`. `vanilla.html` and
  `with-komorebi.html` are unused and still contain them.

The bar shows, left to right: logo, GlazeWM workspaces, date, binding modes,
tiling direction, network, memory, CPU, battery.

## Autostart

Neither GlazeWM nor Zebar currently autostarts — there is no entry in
`HKCU\...\Run`, no scheduled task, and nothing in the Startup folder.

For Zebar, use the GUI: tray icon -> `Widget packs` -> `<pack>` -> `<widget>` ->
`Run on startup`. That is equivalent to keeping the `startupConfigs` entry in
`settings.json`. For GlazeWM, start `glazewm-watcher.exe` at login.

## Providers

System data reaches widgets as reactive *providers* from the `zebar` npm
package, declared as a group:

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

Available: `audio`, `battery`, `cpu`, `date`, `disk`, `glazewm`, `host`, `ip`,
`keyboard`, `komorebi`, `media`, `memory`, `network`, `systray`, `weather`.
Read values from `providers.outputMap` and re-render in
`providers.onOutput(...)`.

Most widgets are **buildless** — React runs in the webview from a CDN via a
`text/babel` script tag, so there is no build step. The Solid/TS templates do
need Node plus a `pnpm build` after edits.

## Troubleshooting

**Check the log first:** `%USERPROFILE%\.glzr\zebar\errors.log`. Empty means a
clean start. Delete it before restarting to get a fresh signal.

**Restart Zebar after editing a pack.** Pack discovery runs once at startup.
`WidgetPackManager::reload()` exists in the source but is not exposed as a
Tauri command, so there is no way to trigger it — a running instance will not
notice a new pack directory or a changed `zpack.json`.

**Zebar fails to start on Windows.** Usually a stale WebView2 runtime. Install
the Evergreen Standalone Installer as admin:
<https://developer.microsoft.com/en-us/microsoft-edge/webview2/>

## Rebuilding from scratch on a new machine

1. Install GlazeWM, then Zebar, then Emacs.
2. Clone this repo to `%USERPROFILE%\dotfiles`.
3. `.\deploy.ps1` to push the configs.
4. Start Zebar once and let it fetch its webview runtime.
5. In the Zebar GUI, confirm `my-bar` / `with-glazewm` is the startup widget.
