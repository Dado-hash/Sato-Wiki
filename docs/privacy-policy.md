# Privacy Policy

SatoWiki is privacy-first.

- No third-party analytics in the core app.
- No account required for reading.
- Content bundle updates are static file downloads.
- Preferences and reading state stay on device.
- Followed BIPs, when implemented, stay local unless the user enables notifications.
- Lightning tips remain mock-only until payment privacy and consent UX are finalized.
- The block explorer is off by default. It contacts a server only after the user turns it on and starts a search. See the section below.
- The tools that work offline (hashing, converters, decoders, demos) make no network calls.

Data stored locally:

- last visited tab;
- preferred reading level, language, theme and reader text size;
- bookmarks, reading progress and recent searches;
- latest valid content bundle and its media;
- future followed BIP IDs;
- block explorer settings (on or off, server address).

## Block explorer

The block explorer is the only part of SatoWiki that contacts a server, and only when you ask it to.

- It is off when the app is installed. While it is off, nothing is sent to any server.
- You turn it on in Settings, under Explorer, after a screen that explains what is sent. You can turn it off again there, or with "Turn off the explorer" on the explorer screen.
- When you press Search, or tap a block, transaction or address link inside a result, the app sends that one query to the server shown on the explorer screen: a block height, a block hash, a transaction id or an address. A height first asks for its block hash. A 64-character hash may be asked as a transaction and then as a block.
- The default server is mempool.space (`https://mempool.space/api`). You can enter your own server. It must use https, or http only for localhost, `.onion` or `.local` addresses.
- The server sees your IP address and what you search. If you look up your own addresses, the server can link them to your IP address.
- The explorer does not use Tor or any other proxy.
- A private key or an extended key pasted into the search box is never sent. The box is cleared.
- The app sends one request per action. It does not poll, refresh or retry on its own. If the server asks the app to slow down, the app waits and says how long.
- Results are kept in memory for the current session only, so the app can show them again without asking the server twice. Turning the explorer off, or closing the app, clears them.
- Searches are not saved. There is no search history on the device, and nothing searched is written to settings. Only the on/off switch and the server address are stored.

No personal data is sold or shared.
