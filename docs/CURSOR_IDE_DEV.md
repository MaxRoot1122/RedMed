# RedMed — Cursor IDE dev layout

Run the app **inside Cursor** (web preview panel + optional native sim stream) while editing and using the agent.

## One-time setup

1. **Install extensions** (Cursor will prompt from `.vscode/extensions.json`):
   - [SweetPad](https://marketplace.visualstudio.com/items?itemName=SweetPad.sweetpad) — build/run iOS from the IDE; simulator **stream** in an editor tab
   - [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) — debug attach

2. **SweetPad:** Command Palette → `SweetPad: Generate Build Server Config` (creates `buildServer.json` for Swift jump-to-def).

3. **Optional:** `brew install xcode-build-server xcbeautify` for faster SweetPad builds.

## Start dev stack

**Command Palette** (`Cmd+Shift+P`) → **Tasks: Run Task** → **RedMed: IDE dev stack**

That starts:
- Local web server on `http://127.0.0.1:8934`
- iPhone 17 simulator + builds/installs native **RedMed**

## In-IDE preview (web — stays in Cursor)

With the web server running:

1. `Cmd+Shift+P` → **Simple Browser: Show**
2. URL: `http://127.0.0.1:8934/dev/iphone17-preview.html`

Drag that tab **beside** your editor. Edit `index.html` → click **Reload preview** in the frame (or refresh the Simple Browser tab).

**Cursor setting:** *Tools & MCP → Show Localhost Links in Browser* = **On** so port links open inside Cursor, not external Chrome.

## In-IDE preview (native iOS — SweetPad stream)

After SweetPad is installed and the sim is booted:

1. Command Palette → search **SweetPad** → **Stream Simulator** (or **Show Simulator**)
2. Opens a **webview tab in Cursor** with the live iPhone 17 screen
3. Split: Swift files left, sim stream right, agent chat where you want it

Build/run from SweetPad sidebar: scheme **RedMed**, destination **iPhone 17**.

NFC still requires a physical iPhone; everything else works in sim.

## Layout sketch

```
┌──────────────────────┬──────────────────────┐
│  index.html / Swift  │  Simple Browser        │
│  (editor)            │  iphone17-preview      │
│                      │  OR SweetPad sim stream│
└──────────────────────┴──────────────────────┘
│  Agent chat (bottom or side)                  │
└───────────────────────────────────────────────┘
```

## Tasks reference

| Task | What it does |
|------|----------------|
| `RedMed: IDE dev stack` | Web server + iPhone 17 build/run |
| `RedMed: serve web (8934)` | Web only |
| `RedMed: build & run on iPhone 17` | Native app on sim |
| `RedMed: boot iPhone 17 simulator` | Sim only |

Default build shortcut: `Cmd+Shift+B` → build & run on iPhone 17.
