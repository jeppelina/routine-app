# Otis, Loui & Teddys Rutiner!

A single-file PWA (`index.html`) for kids' morning/evening routines, with optional
cross-device sync through Supabase. It has no build step and no dependencies to install.

## Run it locally

```bash
npm run dev
```

Open <http://localhost:5173>. The page reloads automatically when you save `index.html`.

- To open it on a phone on the same Wi-Fi, use `http://<your-computer-ip>:5173`.
- If you don't have Node, `npm run serve` (Python) also works, but without live reload.

### Cloud sync is off locally

On `localhost`, a LAN IP or `file://`, the app runs **offline on localStorage**. It
never reads or writes the real household in Supabase. A console message confirms this.

- Add `?sync=1` (for example `http://localhost:5173/?sync=1`) to deliberately sync with the
  real household data.
- To reset local state, clear site data in DevTools (Application → Storage), or run
  `localStorage.removeItem('routineData_v2')` in the console.

The deployed site is unaffected and always syncs.

## Supabase

`supabase/schema.sql` holds the schema. A GitHub Action
(`.github/workflows/supabase-keepalive.yml`) pings the project every day so it doesn't
auto-pause.
