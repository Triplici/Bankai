# Bankai Guild website aggregate

`BankaiGuildSiteAggregate` is a small addon shipped beside `Bankai Guild` and `BankaiGuild_Arena` in the
official ZIP. It prepares one masked aggregate from the current character's own native guild
roster. It does not upload anything, run in the background, identify the player or expose the
main addon's SavedVariables.

## What it can export

Only an exact Alliance guild named `Bankai Guild` or `Bankai Guild I` through `Bankai Guild X` is eligible. The
source must be Bankai Guild's public census-checkpoint API v1 and the matching row must be:

- the current character's native roster, never a relay or `/who` row;
- fresh, counted and undisputed;
- timestamped against the game's server clock; and
- no more than 15 minutes old, inside a checkpoint no more than 60 seconds old.

The dedicated `BankaiGuildSiteAggregate` SavedVariable contains only the schema and producer
versions, server-clock capture time, realm group, faction, canonical guild name and
masked character/online counts. It never copies player or reporter names, character/member IDs,
GUIDs, chat, guild or network keys, notes, ranks, officer lists, linked-alt estimates or a
reference to `BankaiGuildDB`.

Positive counts below five are written as `few`. If an exact online count would reveal an
offline remainder from one through four, online is written as `unavailable`.

The accepted `.198` reporter contract is intentionally exact: producer `1.3.2-site.1` and seven
root keys, without an additive expiry field. The reporter validates the original server capture
and observation times, withholds online after 15 minutes, refuses source data after 24 hours, and
expires a selected private review after five minutes. Changing that shape requires a coordinated
website parser release; the addon does not pretend a newer schema is already accepted.

## Deliberate local workflow

1. Log into the character in the guild being reported and open the game's Guild roster. Wait for
   Bankai Guild to have a current own-roster census row.
2. Type `/bk site export` (or the compatibility alias `/olysite export`). No event, timer or
   network path invokes its private preparation
   function; this command is the deliberate product flow to prepare a local file, not consent to
   publish it. WoW addons share one Lua environment, so this is not a security boundary against
   other installed addon code.
3. Read the result in chat. A refusal clears any pending in-memory export.
4. Type `/reload` immediately. The game writes
   `WTF/Account/<ACCOUNT>/SavedVariables/BankaiGuildSiteAggregate.lua` separately from
   `BankaiGuild.lua`.
5. Review and select **only** `BankaiGuildSiteAggregate.lua` in the attended website reporter. Its
   source times remain unchanged; the site applies its source-age rules and the selected private
   review then expires after five minutes.
6. Preview the proposed publication on the website and consent there separately.

The addon clears an older session's value as soon as the game restores it at login or reload
(on `ADDON_LOADED`), so only an export made in this session is written. After the `/reload` that
writes a new export, upload it before another logout or reload, which writes the cleared state.
Changing guild after `/bk site export` also withdraws the pending value. `/bk site clear` plus
`/reload` explicitly removes it. Both commands have `/olysite` compatibility aliases.

## In-game acceptance before publication

These client-dependent checks cannot be proven by the offline Lua harness:

1. Install the generated ZIP and confirm the AddOns screen lists `Bankai Guild`, `Bankai Guild Arena` and
   `Bankai Guild - Site Aggregate` on Forever, Classic Era and Anniversary/TBC.
2. On an Alliance character in each of `Bankai Guild`, `Bankai Guild I` and `Bankai Guild X`, open the roster,
   run `/bk site export`, and confirm the success line names only that current guild.
3. Run `/reload`; inspect only the dedicated file and confirm it has exactly the fixed seven-key
   `.198` contract above and no name other than the guild name.
4. Confirm no HTTP request, addon message, whisper, guild-roster request, popup or automatic
   upload occurs.
5. Repeat while outside a guild, in a differently named guild, with a stale roster and after a
   guild change; each case must refuse or withdraw and leave no aggregate after the next save.
6. Exercise counts 0, 1-4, 5 and a 1-4 offline remainder in a controlled test guild. Confirm zero
   is refused, positive small counts are masked and the complementary remainder stays hidden.
7. On the website, confirm source data older than 24 hours and unexpected keys/types are rejected,
   online is withheld after 15 minutes, a selected review expires after five minutes, and
   publication still needs a separate explicit action.

## Rollback and removal

Quit the game, delete `Interface/AddOns/BankaiGuildSiteAggregate`, and reinstall the previous complete
Bankai Guild ZIP so the other two folders stay on matching versions. The dedicated SavedVariable is
inert without the addon. To remove it too, delete
`WTF/Account/<ACCOUNT>/SavedVariables/BankaiGuildSiteAggregate.lua`; do not delete `BankaiGuild.lua`
unless the user also wants to remove their Bankai Guild settings and history.
