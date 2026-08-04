# Privacy & data handling

RedMed bands are designed to be readable by anyone in an emergency with **no
login, no passcode, no app install** — every second matters, and an
authentication step defeats the purpose. This document explains the tradeoffs
that make that safe.

## How the data moves

- A band's NFC chip stores a single HTTPS URL:
  `https://redmed.pages.dev/card/#d=<encoded profile>`.
- The profile is encoded in the URL **fragment** (`#d=...`). Browsers never
  send the fragment to a server on page load — it's decoded entirely on the
  scanning phone, client-side, in `card/index.html`.
- `card/index.html` ships with `Content-Security-Policy: connect-src 'none'`,
  so the page cannot make network requests even if one were added by
  mistake later. There is no analytics, crash reporting, or tracking script
  anywhere in the card page.
- There is no backend, database, or API for this project. The card page and
  `get.html` are static files; nothing about a scan is recorded by RedMed.

**Net effect:** RedMed (the developer) has no way to see when, where, or how
often a band is scanned, or by whom. The only party who could theoretically
see anything is the static host's own infrastructure-level web logs (IP,
timestamp, path) — standard for any web request, outside this codebase, and
never tied to a specific band since the profile data itself never reaches
the server.

## Why this generally isn't HIPAA-regulated data

HIPAA applies to "covered entities" (providers, insurers, clearinghouses)
and their business associates. RedMed profiles are entered directly by the
individual, with no covered entity in the loop, so this data does not meet
the definition of PHI under HIPAA. That said, we still treat it as sensitive:

- **Data minimization.** The profile schema only holds what a first
  responder needs — name, DOB, blood type, allergies, medications,
  conditions, emergency contacts. There is no field for SSN, insurance ID,
  or other data that would enable identity theft if scanned by a stranger.
- **Informed consent at write time.** The app tells the owner, before they
  write a band, that anyone who taps it sees the data instantly with no
  login — so they can choose what to include.
- **Revocability.** The owner can delete their profile from the app at any
  time (My ID → Edit Profile → Delete My ID), and can overwrite a band with
  a blank profile to erase what's on the physical chip.

## What we can't control

Once a band is written, the URL it points to works like any public web page
— we can't prevent someone from screenshotting or copying a scanned card.
That's an inherent tradeoff of a no-auth, life-critical design, and it's
disclosed to the owner before they write their band.
