# SoaresUtils

A "Set and Forget" automation tool for LSPosed and Magisk. Automatically enforces module scopes and system configurations to ensure Niantic games remain hidden from detection without manual maintenance.

Runs automatically on **Boot** or via the **Magisk Action Button**.

---

### Core Features
- **Zygisk Enforcement:** Automatically monitors the Magisk database. If Zygisk is disabled (common on some devices after updates or clears), the tool flips it back to 'On'.
- **LSPosed Automation:** Automatically injects the correct scope for the **Hide Mock Location** module into the LSPosed database.
- **Fail-Safe Logic:** Uses a localized `sqlite3` binary to ensure database changes work even if the system environment is restricted.

---

### Supported Apps
- **System Framework** (Required for module injection)
- **Pokémon GO** (`com.nianticlabs.pokemongo`)
- **Pokémon GO (Samsung Galaxy Store)** (`com.nianticlabs.pokemongo.ares`)
- **Monster Hunter Now** (`com.nianticlabs.monsterhunter`)
- **Ingress** (`com.nianticlabs.ingress`)

---

## Changelog

### v1.2
- **Zygisk Health Check:** Added an automated checker to ensure Zygisk is enabled in `magisk.db`. This acts as a fail-safe for devices that occasionally boot with Zygisk disabled.
- **Architecture Stability:** Integrated a standalone `sqlite3` binary for reliable database updates, bypassing Magisk CLI string-parsing issues.
- **Action Button Feedback:** Added console output to notify the user immediately if Zygisk was enabled and a reboot is required.

### v1.0
- **Initial Release**
- Automated scope enforcement for Pokémon GO, Monster Hunter Now, Ingress, and System Framework.
- Centralized logging to `/data/local/tmp/soaresutils.log`.

---

## Usage & Troubleshooting
* **Logs:** View execution history at `/data/local/tmp/soaresutils.log`.
* **Note:** If the tool detects Zygisk was OFF, it will enable it, but you **must reboot** the device manually for Zygisk to become active in memory.