# Custom domain (optional)

**Active host today:** `https://maxroot1122.github.io/RedMed/` — see [`config/canonical-url`](../config/canonical-url).

There is **no separate marketing website** and no custom domain in production yet. Store / support contact is email only (`help.RedMed@gmail.com`).

When you register a domain you control and want it for shorter NFC URLs, Universal Links, and apex Asset Links:

## Why a custom domain later

- Shorter NDEF URI → more medical data fits on NTAG215/216
- Apex `/.well-known/assetlinks.json` for full-screen Android TWA
- Apex `/.well-known/apple-app-site-association` for iOS Universal Links
- One canonical URL for packaging ([`docs/BRACELET.md`](BRACELET.md))

**Do not use `redmed.app`** — unrelated third-party storefront.

## Steps

1. Register a domain you own. Point `www` (and apex if desired) at GitHub Pages (`CNAME` → `maxroot1122.github.io`).
2. Confirm `https://YOUR.DOMAIN/index.html` serves **this** app (not a registrar lander).
3. Put `YOUR.DOMAIN` in a root `CNAME` file and push (Pages workflow publishes it when present).
4. Edit [`config/canonical-url`](../config/canonical-url) to `https://YOUR.DOMAIN/index.html`, then:

```bash
./scripts/sync-canonical-url.sh
./scripts/sync-www-mirror.sh
```

5. Add `applinks:YOUR.DOMAIN` to [`ios/RedMed/RedMed.entitlements`](../ios/RedMed/RedMed.entitlements).
6. Confirm AASA JSON at `https://YOUR.DOMAIN/.well-known/apple-app-site-association`.
7. Paste Play signing SHA-256 into [`.well-known/assetlinks.json`](../.well-known/assetlinks.json) before relying on TWA verification.

## Until then

New tags use `https://maxroot1122.github.io/RedMed/index.html`. GitHub project Pages cannot host apex `/.well-known` for Universal Links / Asset Links — that needs a custom domain.

## Single repo rule

All hosting stays in **this** repo (`MaxRoot1122/RedMed`). Do not create a separate `github.io` user-site repo.
