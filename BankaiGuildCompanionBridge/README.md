# Bankai Guild Companion Bridge

This is the private, passive handoff addon for the Bankai Guild Companion. It depends on
`Bankai Guild`, has no UI or network transport, and declares exactly one SavedVariable:
`BankaiGuildCompanionDB`. The public Bankai Guild package remains unchanged: `scripts/package.sh`
packages `BankaiGuild/` and `BankaiGuild_Arena/`, but does not include this private bridge.

For installation and updates, `BankaiGuild/` and `BankaiGuild_Arena/` are one inseparable Bankai Guild release
bundle. They always have the same owner and move through update, migration, staging, integrity
verification, and rollback together. The Companion owns this sidecar independently of the selected
BankaiGuild-bundle manager. In CurseForge or another external-manager mode, that manager alone writes
`BankaiGuild/` and `BankaiGuild_Arena/`, while the Companion may install and update only
`BankaiGuildCompanionBridge/` after the user's account is eligible for checkpoint features. In
Companion-managed mode it updates the two Bankai Guild bundle directories through one guarded,
recoverable bundle operation and manages the Bridge through its separate package. Manual mode
offers one exact Bankai Guild bundle and, when the account is eligible, the separate Bridge package
with an explanation of why it is needed.
No mode edits an external manager's private state or silently removes its ownership.

## Private package

The Bridge is never in the public Bankai Guild package (`scripts/package.sh` ships `BankaiGuild/` and
`BankaiGuild_Arena/` only). Its private, deterministic package script lives with the Companion app and
arrives with it.

Packaging refuses dirty tracked source; missing, untracked, ignored, or extra Bridge files; unsafe
TOC paths; executable or symlinked inputs; the main addon's `BankaiGuildDB` SavedVariable; common
SavedVariables/credential filenames; and recognizable private-key or token material. It stages
from `HEAD`, never from a live WoW directory. In particular, neither `BankaiGuild.lua` nor any account's
main SavedVariables, local credentials, or signing keys belong in this package. The SHA-256 file is
an integrity checksum, not a signature; this script neither creates nor expects a signing key.

This is packaging infrastructure only. It does not install or update the Bridge, enroll a user,
deploy an artifact, publish it, or make the Companion updater live. `scripts/package.sh` remains
the public two-folder `BankaiGuild/` + `BankaiGuild_Arena/` packager and does not include this Bridge.

## Boundary

At `PLAYER_LOGOUT` (also used by `/reload` and game exit), the bridge asks the additive
`BankaiGuildBridge.CENSUS_CHECKPOINT_API_VERSION == 1` API for a fresh, read-only census
snapshot. It copies only the documented allowlist into a new table. It never reads or
writes `BankaiGuildDB`, and the checkpoint contains no member, officer, reporter or council
identity; no chat, keys, moderation records or settings; and no references to Bankai Guild's
internal tables.

The checkpoint contains only:

- schema/version, capture times, realm, realm group and faction;
- total/online/fresh aggregate counts;
- bounded per-guild aggregate counts and identity-free provenance;
- bounded `/who`-seen-only guild aggregates; and
- a previous checkpoint key, bounded tombstones and a tombstone floor.

All arrays are sorted by their stable guild key. Strings are plain and bounded. The
bridge rejects a malformed, oversized or inconsistent source instead of overwriting the
last good checkpoint.

The SavedVariable has this versioned shape (question marks mean optional fields):

```text
BankaiGuildCompanionDB = {
  schema = "bankaiguild-companion-db", version = 1,
  checkpoint = {
    schema = "bankaiguild-census-checkpoint", version = 1,
    key, previousKey?, capturedAt, capturedAtServer?, timeSource,
    scope = { realm, realmGroup, faction },
    summary = {
      members, characters, linkedAlts, online,
      guilds, freshGuilds, seenOnlyGuilds, newestObservedAt,
    },
    guilds = {
      { key, name, members, online, fresh, counted, observedAt,
        observedAtServer?, provenance = {
          source, realm?, heardOn?, reporters, disputed, singleSource,
        } },
    },
    seenOnly = { { key, name, online, capped, observedAt } },
    tombstones = {
      { key, name, removedAt, removedAtServer?, lastObservedAt,
        lastObservedAtServer?, previousKey },
    },
    tombstoneFloor, tombstoneFloorServer?,
  },
}
```

`guilds` and `seenOnly` contain at most 256 entries each; `tombstones` contains at
most 512. `summary.guilds` counts every exported guild row, while characters and
online come only from rows marked `counted` and `fresh` respectively. Fresh rows are
always counted, per-guild online never exceeds that row's character count, and the addon's known
linked alts are subtracted once to produce the legacy estimate `summary.members`. That field is
not an exact count of humans or Link-verified unique accounts; those are separate identity metrics.

## Removal rule

A missing previously reported guild creates a tombstone. A later record for that key is
live only when its server observation time is newer than the tombstone's server removal
time; when either server time is unavailable, compare the local observation and removal
times instead. A record at the same time is still removed. Records at or before the
tombstone floor are also removed. This lets a genuinely newer report restore a guild but
prevents an imported old checkpoint from resurrecting it.

## When the file changes

WoW does not continuously write SavedVariables while a character is online. The Lua
table is finalized during `PLAYER_LOGOUT`, but the client writes
`WTF/Account/<ACCOUNT>/SavedVariables/BankaiGuildCompanionBridge.lua` only as part of
`/reload`, logout or game exit. The desktop companion must wait for that write to finish,
read a stable file, and keep the preceding valid checkpoint if parsing fails.

## Sections

Besides the census checkpoint, Bankai Guild offers versioned read-only sections through
`BankaiGuildBridge.RegisterSection(name, version, exporter, limits)` / `GetSection(name)`
(`BankaiGuild/Bridge.lua`, exporters in `BankaiGuild/BridgeSections.lua` and `BankaiGuild/BridgeAffairs.lua`).
Bankai Guild copies each into fresh plain tables within `BankaiGuildBridge.SECTION_LIMITS` (or the larger
limits a section asked for, never past `BankaiGuildBridge.SECTION_MAX`). At logout this sidecar saves
only the sections it knows, at version 1, under `BankaiGuildCompanionDB.sections`: `guilds`,
`rankings`, `stats`, `wanted`, `self`, `realm`, `roster`, `church`, `games`, `profile`, `crafting`,
`crafters`, `treasury`, `decrees`, `agenda`, `notices`, `watch` and `chatRooms` (a name Bankai Guild
does not register is simply absent). `stats` is the census statistics page's figures
(`docs/CENSUS-STATS.md`). A failing or unknown section is skipped and never blocks the census.

The affairs' sections (`BankaiGuild/BridgeAffairs.lua`), each nil before the Bankai Guild Accord is accepted
and for a character who is no member:

- `crafting`: the request board's open cards (100: item, quantity, guild, state; no requester, as
  the board names none) and this character's own open deals (30: the same and the other party);
  never the terms, the price or the request's chat;
- `crafters`: the crafters' directory (300, the best skill first): name, guild, professions with
  their skill, cap and recipe count;
- `treasury`: the public numbers alone, only while the Shogun shows the balance (`shown = false`
  otherwise): balance, in, out, this week's donations and donors; never an item or a name;
- `decrees`: the Decrees tab's decrees (30): kind, whole army or one guild, role and name of the
  sender (no role for a councillor's while the Shogun's screen hides the councillors' names), zone,
  words as the page shows them, times;
- `agenda`: the week (30, soonest first): the Shogun's Agenda and dated entries, this guild's
  calendar events, the Arena's fights;
- `notices`: `{ items }` (30, newest first): musters (and those ended within a day, as withdrawn,
  with the same audience and role; an ended one this character's client may not place is left
  out), the Crown's and the High Council's decrees for the whole army, and this character's own
  letters from the Shogun (`audience = "self"`: his alone);
- `watch`: only on a moderation team client or for the desk's own staff: counts, the cases, the
  guild's records, the inspected players and the untabarded list (100 each), on the Shogun's stream
  as the page shows them there (an accused name cut short until upheld, no report counts or
  dates); never a reporter, a note, an evidence line, a moderator's reason or a chat line;
- `chatRooms`: the rooms this character is in, with member and unread counts; no chat text.

What a section may carry: only what this character's own client already shows on Bankai Guild's own
pages, to the audience that page has. Staff-only sections (`watch`) exist only on the clients whose
page shows them; personal rows (`crafting.own`, the letters in `notices`) carry this character's
own. The `self` section is `{ character = "Name-Realm", battleTag = "Name#1234", accord = 1,
at = <server time>, guild = "Guild Name", bankaiguild = true, roles = { "officer", "guildMaster",
"council", "crown", "author" }, tabs = { ... } }`: the player's own character and BattleTag as
his own game gives them, current native Bankai Guild guild, roles and actual tabs. It is named only after
both the Bankai Guild Accord and the separate Bankai Guild Companion Accord are accepted. The BattleTag is
staff-only display/linking data and never membership or witness authority. Before consent, after
withdrawal, outside an Bankai Guild guild or while the game cannot authenticate the tag, it is the
anonymous revocation `{ bankaiguild = false, roles = {}, tabs = {} }`, so the relay can remove a stale
identity. It carries never another player's BattleTag (not the ones a moderation team client keeps).
Never chat text or
chat-strike lines, another player's private data, treasury items (numbers only, and
only while the Shogun publishes the balance), or anything private to an audience the player is not
in.

LAN synchronization and encryption are deliberately not responsibilities of this Bridge slice.
The Companion core has an encrypted-envelope/replay protocol foundation, but discovery, pairing,
production cryptography, sockets, persistence, and actual desktop/mobile exchange are not live.
