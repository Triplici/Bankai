# Elfcore

**The whole Elfcore army in one window, inside World of Warcraft: Forever.**

Elfcore is Asmongold's guild for *World of Warcraft: Forever*: Alliance, PvP ruleset, a
place to find dungeon groups, organize raids, share class knowledge and build the guild
together. It grew past **10,000 members during the beta**. A WoW guild caps at 1,000
members, so Elfcore is really a *realm* of many Elfcore guilds. In game each player
only ever sees the roster of their own guild. Nobody could tell how many Elfcore guilds
exist, who leads them, or where the army is.

This addon answers exactly that. It adds up every Elfcore guild live, in a window that
looks like Blizzard's Guild window and docks right next to it.

![The whole army at a glance: every Elfcore guild, live](https://raw.githubusercontent.com/dnl-gentile/elfcore-addon/main/docs/elfcore-1.jpg)

![Where the army stands: soldiers per zone on the world map](https://raw.githubusercontent.com/dnl-gentile/elfcore-addon/main/docs/elfcore-5.jpg)

> **Status:** built for WoW: Forever and running on the Forever beta (1.60.1), where the
> census already adds up reports from many Elfcore guilds. Also tested on Classic Era (1.15)
> and Anniversary (2.5). Please report anything that looks wrong (`/elf bug`).

---

**Horde too.** Elfcore guilds on the Horde side use the same addon. The factions can't see
each other's guilds, so each one gets its own census, channels, decrees and untabarded list: the
addon picks yours from your character. On the Horde, the Crown is every Horde Elfcore guild
master and the officers of the Horde guild named exactly "Elfcore", if there is one.

## Recent versions

- **1.3.3**: Deliberate site export: an optional Site Aggregate folder writes a masked own-guild count for the
  Elfcore website on /elf site export and /reload, never uploads, and empties at the next logout or reload.
- **1.3.2**: Correction: explicitly approximate Census people counts, preserve accepted Treasury rows,
  fix full-suite ordering regressions and export consented Companion identity evidence.
- **1.3.0**: Shared durable records and rankings; Church catch-up; Wanted and Slayers pagination,
  rebalanced history and recent map sightings; the current Legate structure; safer Watch records;
  Companion exports after the Accord; and integrated Arena, Bones and chat fixes.

Every version's notes are in the [GitHub releases](https://github.com/dnl-gentile/elfcore-addon/releases). This page is the short one for CurseForge: the [README](https://github.com/dnl-gentile/elfcore-addon#elfcore) has every section in full.

## Who can use it

**Only members of a guild with "Elfcore" in its name**, however it was spelled: OLYMPVS the Roman way, Olimpus, Olmps, Olympuz, Olympos, Olimpo and other misspellings count too (Olympia or Olympic do not), and a guild against Elfcore ("ANTI ELFCORE", "Elfcore Haters") does not. The check is fixed in the code and
cannot be switched off with a command. Outside an Elfcore guild the addon joins no channel
and hears nothing of the army, but for the author's signed list below, over its own guild.
The only thing it offers there is the **Join Elfcore**
screen described below, and its own few addon whispers are the only ones it sends or hears
there (1.1: which guild to ask, the answer, and your request, each to or from the one member
concerned). Using it requires accepting its terms, the Elfcore Accord, which shares your BattleTag with Elfcore's staff only.

**Approved guilds (1.1).** A guild of Asmon's Elfcore whose name the rule leaves out (it leaves
Olympian and Olympia out on purpose) counts as an Elfcore guild once the author names it in his
signed list: the same list, signed with the same key on his own computer, that names the High
Council and the King's Steward, for one faction and realm group. No census vote counts, and nobody
else can add one. A few ship with the addon itself, so their members have nothing to paste: since
1.1, the Alliance's `<ELF>`, and since 1.1.5 its `<ELVES>` too (only a new version takes one of those off). Its members' addons, no Elfcore members
until they hold that list, take it over their own guild alone (the list only: nothing else is
read, and they send nothing). The first of them pastes it with `/elf approved paste`, or a click
on the Join Elfcore screen's last line (the author
or a High Councillor hands out the signed text; it is checked like any list, so it can't be forged
or changed), and his addon passes it to his guild every 5 minutes. `/elf approved` lists the
approved guilds of your faction. A newer signed list without a guild ends it on every client.

**Removed guilds (1.1.5).** A guild the High Council removed from Elfcore is no Elfcore guild,
whatever its name: its census, chats and marks are gone and its members' addon shows the Join
Elfcore screen. Its way back is an appeal to the council: once the author names it in his signed
approved list, it counts again, with no new version. Until a player updates, the council's
[net-off](#net-off-11-the-moderators-hide-a-character-or-take-a-guild-off-the-network) word takes
such a guild off the network live.

### Not in Elfcore yet?
First it asks the obvious question: *"<Your Guild>? Disband immediately. What are you
doing?"* Then it helps you get in. The **Join Elfcore** screen uses the game's own `/who` to
find Elfcore members online, groups them by guild, and whispers one of them a ready-made
request that you can edit ("Hi! I'd love to join Elfcore. Does <Elfcore II> have room for
one more?"). No answer? **Try someone else** picks a member you have not asked yet. Replies
are highlighted. It is rate limited, so nobody gets spammed.

**Where to go** (1.1): a search also asks one member's addon (an addon whisper, not a chat line)
where recruits should go, and its census answers: the guild the King opened **the gates** of
first, then the guilds with the **most free slots**, and a couple of their Lords and Captains
online (never the King). It names only what the census confirms: guilds two members' reports
agree on, and Lords and Captains two reports name. The screen lists them in that order, each
once `/who` found one of its members (the gates once a second member's answer agrees: one more
is asked), the guilds found with `/who` too, and a click asks one of those officers that `/who`
found in that guild, or another member it found there. Just before, their addon is asked
whether they take recruit whispers (again if it never answered): a member who set **do not
contact** (`/elf nocontact on`) is never offered, however many recruits ask him, and the
question closes before anything is sent. It stays **one whisper per click**, in your
own words (no dues line), 20 seconds apart. With it goes your request to the same member, so an
officer's addon shows it with **Invite** and **Decline** instead of a raw whisper. Members on
versions before 1.1 just get the whisper, as before.

## What it does

### Census: the army at a glance
- Every Elfcore guild in one list: **Guild · Members · Online · Avg lvl · Lord**. Columns sort by
  clicking, like the Guild window.
- **Total soldiers** and **online now** across the whole realm.
- **Where the army stands**: top zones ("Stormwind City 742") and totals per continent
  (Eastern Kingdoms, Kalimdor), counted by the guilds whose census comes from a member who
  shares their zone (see Privacy, below).
- Hover a guild: members, online, free slots, average level, inactive members, classes online, top zones.
- **Right after login** (1.1) the header, the Census and the Realm say *Rebuilding the census
  after login: N guilds heard so far* for about 3 minutes, while every guild's reporter answers.
  The beta often loads an empty save: the army is not gone, and no `/reload` is needed. The line
  only waits: it asks nothing (no `/who`) and opens nothing.
- **An update line** (1.1): when the author's own addon says on the Elfcore channel that a newer
  version than yours is out (he marks it once CurseForge lists it, never a build he is still
  trying), a line at the foot of the Census, one line in chat once a session and `/elf status`
  say so. It is yours alone: nothing is sent and nobody is whispered.
- **Marked rows** (1.1): a warning mark on a guild whose senders disagree (on its Lord or
  Captains, or on its size, by more than 5 members or 5% plus the 20 a minute a guild may gain or
  lose between their two reports), a question mark on one that a single
  sender stands behind. Its tooltip says which and who: check before calling a muster or opening
  the gates on it (the gates ask again, with the reason). A marked row can still be right, and
  the mark changes nothing that counts. Your own guild (your roster) is never marked.
- **Asking to join** (1.1): a recruit who asked you from the Join Elfcore screen shows on top of
  the Census, with their whisper. An officer (the game's guild invite permission) answers with
  **Invite** (the game's own guild invite) or **Decline** (one whisper pointing to the gates'
  guild while the King's gates are open, else naming your guild alone: never a guild the census
  lists for its room, which two made-up characters could report), one click each; anyone else
  can point them to an officer online. **Dismiss** sends nothing. In the Realm's Recruiting, one
  click (or `/elf nocontact`) sets your **do not contact** flag.
- **Search the census** (1.1): a guild, a Lord, a Captain, a player of a guild's top five or one
  seen online (the player shows under the guild's row), or a zone ("Stormwind": its soldiers
  and its guilds, most first). Type **recruiting** (or `free 50`) for every guild with room,
  most free slots first and the King's gates on top.
- **Tonight on this client** (1.1): under the list, the most soldiers your addon saw online at
  once tonight and when, and (in its tooltip, and next to a zone you search) how each zone
  filled or emptied since. Counted by your own addon once a minute from the reports it
  already holds, starting about 3 minutes after login once the census is rebuilt: another
  player's client counts its own evening, and nothing is sent.

### The Realm: the hierarchy
- **War Room**: members read their guild's records; its officers and verified War roles manage them.
  No cross-guild writes. Empty lists explain what is missing; role previews cannot act.
- The **King**, then every guild's **Lord** (guild master) and **Captains** (the officer rank
  right below the guild master).
  Each shows level, class and online or *offline 3d*. Long absences show in red
  (`/elf warndays <days>`, 3 by default). **A Lord away** (1.1): when a Lord crosses that, one
  chat line, once per absence: to his own guild's officers from their roster, and to the King,
  his Steward and his Hands for every guild's Lord, by the census's word (a guild that stopped
  reporting included, counted from its last report even when that showed him online). Never a
  popup, and nothing is done to anyone.
- The **Treasurer of Elfcore** (Pyralis Ashandar, chosen by Asmongold's chat) right under
  the King, with a gold coin next to his name wherever he shows, his tooltip and his lines in
  the Elfcore chats included. Only
  that exact character of the guild ELFCORE gets it: look-alikes don't.
- **Members online** under each guild: your own guild's from your roster, any other's from
  `/who`. Opening a guild searches `/who` for that guild alone (up to 50 of its players).
  Click a name to whisper, invite or `/who` them.
- The **ranks** of each guild with how many members hold them.
- **Inactive members**: offline 7+ and 30+ days, per guild. Your own guild's line (or
  `/elf inactive`) opens the list by name (1.1): members offline 7, 14 or 30 days and more,
  with rank, class, level and last online, from your own roster, longest away first. A rank
  that may remove members (as in the game's Guild window: ranks below yours) removes **one
  person per click**, after a question that shows their rank and days away, a few seconds
  apart. There is no kick-all, and nothing is sent.
- **Mentors** (1.1): a Lord opens **Recruits and their mentors** on that page (or `/elf recruits`):
  his guild's lowest rank and whoever joined since he logged in. He clicks a recruit who is
  online, then one of his Captains, and says yes: **one whisper to each** from that click, the
  Captain told who to look after, the recruit told who to ask. The pair shows on his list (his
  client's alone); nothing goes on the channel.
- **Legates and correspondents** (1.1.5): a guild master of an Elfcore guild (not the King's)
  has a tab of his own in the Throne's place, **Guild** (or `/elf nominees`), laid out as the
  King's Hands page: **+ Name a legate** (his target, or a name he types), his list (a click
  takes a title back, asked first), and a line per High Council department to name its
  correspondent. Since 1.2.4, up to 25
  Legates and one correspondent per department (6 at most), members of his own guild only: the
  addon refuses a 26th Legate, a second correspondent for a department, one name twice and
  anyone outside his roster, and says why. By decision of the High Council, Legates and
  correspondents no longer receive the bronze dragon frame merely for their office: a Legate gets
  the Legate shield and a correspondent gets their department's shield. A signed High Councillor
  likewise gets their department shield without replacing the Council's silver frame. Earned
  honours remain round the portrait underneath the separate badge. Offices count only while
  verified in the guild. Existing appointees receive this explanation once; a real office or
  department change explains the new badge again.
  His own client sends the list on the Elfcore channel; every addon takes it from that guild's
  master alone (proven as for his bronze wings: your roster for your own guild, two census senders
  for another), retains accepted bounded lists across logouts and offline periods, and drops the
  duty when a verified removal or change of guild master is seen. `/elf nominees legate <name>`
  (the old `centurion` spelling remains an alias), `/elf nominees correspondent
  <department number> <name>` and `/elf nominees remove <name>` do it in chat.
  A confirmed correspondent also sees a **Guild** workspace for their own department. War and
  Justice duties apply only to their own guild, checked against its fresh roster and its current
  guild master's nomination; neither title grants federal powers. Artisanry links to its existing
  board and says its dedicated workflow is not available yet. Heraldry runs its own guild's
  Decrees, Agenda and musters; its current appointment grants no global Crown authority. A Church
  contact still needs a Church appointment for its private room and recruitment numbers.
  A Legate organizes an agreed raid group of 40 including themselves (up to 39 guildmates),
  coordinating attendance at events, raids and wars. Groups are optional and fluid, not exclusive
  partitions or restrictions on playing with another leader when theirs is offline. The appointed
  character receives a quiet
  explanation once per appointment. They can edit their own group's list, not another leader's;
  existing authorized officers retain oversight. Old oversized saved groups stay read-only until
  an authorized, confirmed replacement archives the original membership privately. No guild
  invitations, removals or native promotions happen automatically.
- **Level race**: the highest level players of the realm.
- **Recruiting**: the guilds that still have free slots, so new players go where there is room
  (the five with the most, then every one on a click, 1.1).
  When the King opens **the gates** of a guild, it tops the list: send new recruits there.
- **Layers** of your zone, named after the highest ranked Elfcore member on each one
  ("Asmongold's layer"), with how many members are there.

### Layer hop: join the King's layer without begging in chat
While Asmongold is online, the top of the Census and the Realm shows **"Ask invite for Asmon
Layer"** with his crown. One click (or `/elf hop`) and the addon does the asking:

- You must already be in his zone (a layer is read per zone): if you are not, the line says
  where he is and nothing is asked.
- It asks the Elfcore players on his layer who can invite (alone, or leading a group with a
  free seat). Only a handful answer, picked at random on each player's side, so a crowd of
  askers is spread over many players instead of flooding one.
- It picks one of them, favouring players outside a group and with fewer recent invites. They
  get **"X wants to join your layer"** with **Invite**, **Not now** and **Always invite**. No
  answer or a no, and the next one is asked. **Always invite** invites the next ones without
  the window while that player is alone or with only the addon's hop guests; clicked while they
  lead a party or raid of their own, it also covers that group until it ends (1.1.5, GitHub
  issue #50: the window came back with every request there). That group's permission is never
  saved: a later group asks first again, after a `/reload` the window asks once more, and
  `/elf layerauto off` ends it at once.
- The invite is accepted for you when that player is one the addon can vouch for (a member of
  your own guild, the King, his Steward or Hands, or, once the author's signed list is on, a Lord
  or Captain of `<Elfcore>` it names; never a census rank); anyone else's, and every invite
  while Blizzard's gamepad UI is on, waits for your click in the game's own invite window. The
  game moves you to the layer, and the addon takes you out of the group as soon as it sees the
  move (or offers a **Leave group** button if it can't tell).

Players alone on the King's layer are asked once per login: **"Asmon is online and you are on
his layer. May the addon invite the players who want to join, and take them out of the group
once they are there?"** with **For Elfcore!**, **Can't right now** and **Invite manually**, and
a **Don't ask me again** box. With For Elfcore! the addon invites on its own (only while you
are alone or with its guests, never into a group of your friends) and lets each guest go after
90 seconds: the guest's addon leaves the group, since only a click may remove someone.

Any other layer in the Realm tab's layer list works the same way: click it. Everyone who
shares their zone and layer (`/elf location on`) and said yes to layer help (1.1: the
first-open page, or `/elf layerhelp on`) helps: a player who keeps them private is never asked, since an offer would tell the asker where they are. `/elf layerhelp
off` stops the requests, `/elf layerhelp on` also forgets the answer to the King's layer
window, `/elf layerauto on` invites them without the window. Helpers must be in the same zone
as the layer they are on, and the King himself is never asked.

*Continued in the README: [Layer hop: join the King's layer without begging in chat](https://github.com/dnl-gentile/elfcore-addon#layer-hop-join-the-kings-layer-without-begging-in-chat).*

### Person details
Click any Lord, Captain, racer or inspected player. Their profile opens in the Elfcore window, at
its size, with the census facts Elfcore knows: level, class, zone, rank and status. **Back**
returns to the same list or Realm subpage, one opened from another first; **Whisper**,
**Invite** and **Who** stay on it (offline: **Who** alone). It is not the Blood Arena
companion's profile, and opening it sends no query. `/elf profile Name` (or `Name-Realm`) opens
one by name. Yours is **My profile** (1.2.4: `/elf profile`, the Realm, the Games tab, the Games
window's **Edit my profile**): **Look** (frame, title, nickname, emblem; one not released yet in
grey), **Icons**, **Who sees what**, **Letters** (the King's), and you as others see you.
Any soldier can reach the Lord of another Elfcore guild in two clicks.

*Continued in the README: [Person details](https://github.com/dnl-gentile/elfcore-addon#person-details).*

### Right-click a player (1.1.2)
Right-click a player (the target frame, party and raid frames, a name in chat, the Who list, the
friends list, a community roster) and the game's menu gets an **Elfcore** part at the bottom:
- **Their version**: "Elfcore 1.1.1 (out of date)", "up to date" or "not seen yet", and under it
  where it came from and when. Guildmates show up by themselves (their addon says hello to your
  guild), and so does a known version on the person card. Opening the menu sends nothing.
- **Check version**: for anyone else, one tiny addon whisper that their addon answers with its
  version and nothing else (a player once every 2 minutes, 6 a minute). Only 1.1.2 and newer
  answer, so no answer in 10 seconds can mean no Elfcore, an older one, a dungeon or raid, or no
  Elfcore guild (outside one the addon sends nothing). The author's check is his roll call to that
  player alone, which every version since 0.9.9 answers, and only after their yes to his roll calls.
- **Ask to update** (1.2.1: the author, the King and the High Council only; others' asks are
  dropped), when they are behind the newest version your addon knows: nothing goes before you
  confirm. On 1.1.2 or newer their addon shows a compact notice with both versions and where to
  update; **Read update** opens a plain-language parchment letter: reviewed public release notes
  and the safe next step. For an older one, confirming opens a whisper you send with the ask. One
  ask per player a day, 5 an hour;
  they see one a day at most, **Don't remind me** hides them for 7 days (on the beta, which forgets
  addon data at login, these last until you log out), and a player they block (`/elf block`) or
  ignore, or one the moderators took off, never gets through. The notice never names a version the
  author has not released. The author's pick sends his usual update window, naming the version he
  marked as out (`/elf released`).
- **Tell them about Elfcore**, when their addon did not answer: a whisper with a short invite and
  the CurseForge link (to get it, or update an old one) opens in Elfcore's own window, for you to
  edit and send yourself. The click sends nothing.
- **Ask for a bug report** (the author alone, on a player running 1.1.2 or newer): their addon
  opens a window of its own, never a game popup, saying the author asks for their Elfcore bug
  report, with **See what is sent** (the exact text, the same as `/elf bug`), **Send** and **Not
  now**. Send goes to him alone, in game; Not now sends nothing; an ask from anyone else is
  ignored. On his side the report he asked for opens by itself in a window you can copy from (the
  sender and time on top, **Select all**), and stays in the Workshop's list; chat gets one short
  line. A report nobody asked for gets its line and the list only. Since 1.1.5 his addon keeps the
  last 30 reports in its saved variables: where the game loads those back, a logout or a `/reload`
  loses none, and his list opens them in the same window, the date on top for one from an earlier
  day. The Forever beta, which forgets addon data at every login, still loses them at each logout
  or `/reload`. No other player's addon keeps any, and the Workshop's copy for Discord says only
  how many came, never who sent them or what they say. His version checks and his
  `/elf status` open in copy windows too. A window that opens by itself takes no keyboard, waits
  until a fight is over, and never covers a report he is reading.
- In a dungeon, a raid or a match the game holds addon messages: the lines that send show greyed
  and say why. Not on yourself, enemies, offline names or Battle.net friends, and only while you
  are in an Elfcore guild. It uses the game's own way for addons to add to its menus (a client
  without it gets no lines); no Blizzard function is replaced, and nothing opens the game's chat
  box.

*Continued in the README: [Right-click a player (1.1.2)](https://github.com/dnl-gentile/elfcore-addon#right-click-a-player-112).*

### Decrees
| Decree | Who | What happens |
|---|---|---|
| **Call to arms!** | The Crown, the High Council, the King's Hands | Alarm for every Elfcore guild: raid warning, sound, red marker at the caller's position for 5 min |
| **Muster here** | The Crown, the High Council, the King's Hands | Rally point: horn marker on the map for 30 min, soft alert |
| **Royal decree** | The Crown, the High Council | A proclamation with free text, as a raid warning to the whole army |
| **Tabard inspection** | The Crown, the High Council | Announces an inspection at the caller's position: wear your colors |

*Continued in the README: [Decrees](https://github.com/dnl-gentile/elfcore-addon#decrees).*

### Channels
Chat for the whole federation, carried by the addon over its hidden Elfcore channel (no
WoW channel number to join). Each channel is exclusive to a rank:

| Channel | Command | Who reads and writes |
|---|---|---|
| **[Elfcore]** | `/ef <text>` | every member of every Elfcore guild |
| **[Captains]** | `/efc <text>` | the Captains (rank 1) and Lords of every Elfcore guild |
| **[Lords]** | `/efl <text>` | the Lords (every guild master, the King included) and the officers of `<Elfcore>` (their lines show to `<Elfcore>`'s own members, and to everyone for the Hands the King's list or a Steward's own names, 1.0.0) |

*Continued in the README: [Channels](https://github.com/dnl-gentile/elfcore-addon#channels).*

### The Chat tab (1.1.1)
The Elfcore chats in a tab of the Elfcore window, **Chat**, right after the Realm, like the chat
pane of the Guild & Communities window. Click the tab, type `/elf talk` (or `/ef`, `/efc` or
`/efl` with nothing after it), or Shift-click the minimap button: each opens the Elfcore window
on its Chat tab, on that channel. `/elf talk lords`
opens it on [Lords]; the same command again closes the window.
When the side column of the new look runs out of room, its canonical tail continues from the
bottom of the window's left edge upward. Reading the right top-to-bottom and then the left
bottom-to-top always gives the same tab order; changing role or debug view never rearranges it.

*Continued in the README: [The Chat tab (1.1.1)](https://github.com/dnl-gentile/elfcore-addon#the-chat-tab-111).*

#### Role rooms (1.2.4)
**Roles**, after Guild: the rooms of the roles you hold, each line a logged whisper to each member.

*Continued in the README: [Role rooms (1.2.4)](https://github.com/dnl-gentile/elfcore-addon#role-rooms-124).*

### The Board: who is looking for a group, and where (1.1)
The Realm tab links **the Board** (or `/elf lfg`): who in Elfcore wants a group right now, from
what each player chose to share, and the King's week.

- **The King's week** (`/elf week`): the King's Agenda for the next 7 days, by day, with your own
  guild's events from the game's calendar among them, so nobody books the army twice. Elfcore
  can't write into the game's calendar: an officer's click opens it on the right day's month and
  says which day to right-click for the guild event. Your client keeps the week across a
  `/reload` or a login, so it shows while the King is offline.
  **Heraldry and guild agendas (1.2.4).** The signed High Council's Heraldry holders and the author
  also schedule for Elfcore, alongside the King's existing verified Steward and Hands. **Schedule
  for your guild** belongs to its own master and verified Heraldry correspondent: a day and hour,
  or `30 Guild gathering`. Entries and signup counts reach that guild alone. Saved entries keep
  their audience, and a roster still loading keeps them hidden until it confirms the issuer.
  Losing the duty stops new entries and repeats; setters may take back their own exact entries.
  Older clients ignore guild Agenda messages; the army wire and old Heritage key stay compatible.
- **The signup sheet**: Sign up on an Agenda entry with the role you claim; it goes to whoever set
  it, alone, and its audience sees the counts (4 tanks, 9 healers...), kept by his client across a
  `/reload`. Nothing checks the role and nothing invites you: whoever runs the event invites by
  hand. Five minutes before an entry you signed, your client alone prints one line with the usual
  alert sound (nothing sent), after a `/reload` too. A guild entry's saved nudge appears only in
  that same guild while its setter still has that duty.
- **Raise a flag** with one click: **Dungeon**, **Raid**, **PvP** or **Layer**, plus a short
  note if you want one (40 bytes at most). A box says first what goes out: your name, level,
  class and guild, the flag and the note, to every Elfcore player of your realm and faction.
  The note goes the way chat does (the game's servers keep it, so abuse can be reported); on the
  King's screen no note shows.
- **Your zone shows on your card only while you share it** (`/elf location on`); otherwise the
  card says the zone is hidden. Never your position.
- **A click on someone's card whispers them.** Nothing invites anyone, queues or forms a group.
- One flag each, an hour at most; a click on yours, or `/elf lfg off`, lowers it at once.
- **Camps**: drop one where you stand (`/elf camp [note]`) so the army reuses a fire already up.
  Its zone only, never your spot; it needs `/elf location on` and ends by itself after 30
  minutes. The Board lists them by zone, and the world map shows one badge per zone with how
  many (mouse and keyboard only; `/elf camps off` hides them). **Bones can be played at a tavern
  or at a camp** (1.1.6): grouped, within about 10 yards, at the same inn or by your camp.

### Net-off (1.1): the moderators hide a character or take a guild off the network
The King, his Steward, a Hand (the King's list or a Steward's) or a High Councillor of the
author's signed list can hide one character for the whole army: **Hide a character** on the
**Decrees** tab (the name or your target, then the reason), or `/elf netoff Name: reason`. Every
addon then hides that character on every Elfcore surface: their [Elfcore], [Captains] and
[Lords] lines (and the lines the Elfcore chats kept), their pinned line, their decrees, their layer and hop offers,
their Vox Populi votes and questions, their requests at court, and (1.1, Konig's review) their
signups to the King's week, their flags and camps on the Board (the camps' map badges too),
their listing, answers and recipe lists as a crafter, and their elite border and nameplate mark
(they show as no Elfcore player). The names their player already linked as alts are hidden with
them (alt links, below). The rest of their guild, and
the census, are not touched: one name stops the spam.

*Continued in the README: [Net-off (1.1): the moderators hide a character or take a guild off the network](https://github.com/dnl-gentile/elfcore-addon#net-off-11-the-moderators-hide-a-character-or-take-a-guild-off-the-network).*

### Alt links (1.1): one player, counted once
One player in three guilds used to swell the army by three and look like three donors. Link your
alts and the census counts people:

*The list is in the README, with the rest of this section: [Alt links (1.1): one player, counted once](https://github.com/dnl-gentile/elfcore-addon#alt-links-11-one-player-counted-once).*

### The Throne (the King and his Hands)
A tab with a crown that only the King sees: the guild master of the guild named exactly
"Elfcore" (of his faction), and on the Alliance that very character, Asmongold Asmongler: the
addon knows him by name, like the Treasurer. It opens on **the Throne Room** (the queue of
his court while it is open, and the army's key), and holding court takes him there. Since 1.1.5
the Treasury has its own tab alone, and under the Throne Room are **the King's guild's Legates**:
up to 25 explicitly appointed members, named by the King or real High Council. A council title
does not automatically appoint a group leader. Each Legate organizes an agreed group of up to
40 including themselves in the War Room. Each of his tools lives where it belongs:

*The list is in the README, with the rest of this section: [The Throne (the King and his Hands)](https://github.com/dnl-gentile/elfcore-addon#the-throne-the-king-and-his-hands).*

### The King's Steward (1.0.0)
The King's right hand, so that he needn't set everything up himself: a character the author
marks as **Steward** in the High Council's signed titles list. On the Steward's client the
Throne opens as the King's, with **Acting for the King** on top of every page, and in the
King's name he:
- names and removes **Hands of his own**, beside the King's (the Hands button on the Throne):
  the King's list stays the King's, and his own is his;
- names and removes the **treasury's keepers**, and sets **what the army sees** of the
  treasury (its three switches), on the Treasury tab, and **sees the whole treasury as the King
  does**: the balance, the ranking, every keeper's shared book and the guild bank, whatever the
  switches (every keeper is told so before he shares his book);
- uses every tool of a Hand: the Agenda, Summon the Lords, the Royal Inspection, Vox Populi and
  the gates;
- sends the **Crown's decrees** for `<Elfcore>` (Royal decrees, Tabard inspections, Calls to Arms,
  Musters), whatever his own rank: every client takes them by his name, `<Elfcore>`'s own
  members' too, and they never wait behind the flood guard, like the King's. For the other
  guilds his [Lords] lines are the Crown's, as the Hands' are.

*Continued in the README: [The King's Steward (1.0.0)](https://github.com/dnl-gentile/elfcore-addon#the-kings-steward-100).*

### The Treasury (its keepers, the King, and the army when the King says so)
A tab with a coin for the treasury's keepers, for the King, and for every member once the King
shows the army something of it (1.1: for every member on the Treasurer's realms, with the dues' button
alone until then).

*Continued in the README: [The Treasury (its keepers, the King, and the army when the King says so)](https://github.com/dnl-gentile/elfcore-addon#the-treasury-its-keepers-the-king-and-the-army-when-the-king-says-so).*

### Tabards: tabard inspection and the untabarded list
- **Patrol**: walk through the crowd and the addon inspects nearby Elfcore members level 15
  and up, one by one (about 28 yards). Younger players are never flagged. It records who wears a tabard, who wears the wrong one and who
  wears none. Players it could not see properly are never accused.
- **Mark** a player (with a note: `/elf mark complained about the rule`) or a whole guild.
- **Gear seen** (1.1, officers): target a player in range (about 28 yards) and click **Inspect
  gear** on the Tabards tab (or type `/elf gear`). The addon inspects him once, in turn with every
  other inspection (one at a time, never in combat), and keeps what he wears in your saved
  variables, under **Gear seen**: a click shows his items in their slots, each with its own
  tooltip. A Captain can check a raid signup's last-seen gear days later without pulling him
  again. Only the guild master and the officer rank right below keep gear; nothing is scored,
  compared or sent, and nobody is told how to play.
- **Shared among officers** (1.1): what an officer's own inspections find (a player without the
  colors or with another tabard, and one caught before who wears ours again) goes to his guild's
  officers over guild addon messages, once a minute at most, and an officer's addon asks the others
  for the day's findings once a session: after its login, or at his yes if that came later. Each
  officer's Tabards page shows them with his own, the officer who found each in its tooltip, for a
  day (his own later inspection of that player replaces it). Nothing is inspected more or sooner for
  it, nothing goes on the Elfcore channel, and only officers (the guild master and the rank right
  below, by each addon's own roster) send or keep it. The King's untabarded list stays his: another
  officer's finding never joins it, never rides in a Royal Inspection's report and never replaces
  what the King saw himself. Off until you say yes (officers get its line on the first-open page, or
  `/elf patrolshare on`); `/elf patrolshare off` stops it.
- Per guild: *"5 of 20 with problems"*.
- **Untabarded** (the "Wall of Shame" before 0.9.2): the players the Royal Inspection found
  without the colors are on the King's list, which only he sees. He alone can let the army see
  it (a switch on the Throne, off by default): then it shows on the Tabards page, quietly (no
  raid warning, no chat line, no sound), and it leaves every screen when he turns it off or
  stops repeating it. Nobody else can publish one. Players under level 15 are exempt: never
  flagged, never listed.
- Hover any player in the world to see their last inspection in the tooltip.

### Loot notes (1.1)
Loot arguments restart every raid because nobody kept last week's decision: the **Loot notes** of
your guild keep it (on the Realm tab, or `/elf loot`).

*Continued in the README: [Loot notes (1.1)](https://github.com/dnl-gentile/elfcore-addon#loot-notes-11).*

### Crafters tab (1.1.4)
"Who can make this?" is a chat scroll: the top-level **Crafters** tab turns it into one
whisper to a named crafter (`/elf craft`).
- When you open one of your professions, Elfcore reads it (its skill, and the recipes you know:
  their recipe and item ids, never a specialization tree) and asks once, in a window of its own,
  whether to list it. With your yes the board of every Elfcore player of your realm and faction
  shows you: your name, guild, that profession and its skill. `/elf crafter off` takes you off at
  once; `/elf crafter on` lists every profession read again.
- **Ask who can make an item**: shift-click it after `/elf craft` (or type part of its name). The
  crafters listed who know its recipe answer by whisper, their addons by themselves; the page shows
  who can, with their skill and the item, and a click whispers one of them. (From 1.2 the tab's
  **Ask who can make an item...** button opens the request page instead: see below.)
- A crafter's row opens a whisper to him and, on a click, the recipes he listed (hover one for the
  item). Search the board by crafter, guild or profession.
- It stays light on the Elfcore channel and on your own messages: your listing goes once at login,
  every 45 minutes, and after a change (a profession listed or taken off 2 minutes after the last
  at the soonest, a skill up 10 minutes), so about 1.3 an hour while you play and 6 at most while
  you level. Your recipes go a part each 6 seconds (10 messages a minute at most), to two players
  at a time, and only while your addon's own messages (the census first) are few; the next player
  is told you are busy and clicks again a minute later.
- Nothing is crafted, ordered, bought or sold for anyone, nothing touches the auction house, and
  nothing is whispered for you: the whisper is yours to write. Old clients ignore the board.

### Crafting requests (1.2)
On the **Crafters** tab, **Ask who can make an item...** opens the request page: search an item
(your own recipes, the recipe lists other crafters sent you, the answers to your `/elf craft` ask,
and gathered herbs, ores and leathers) or paste its link, choose the quantity and the details, and
publish the request to the board.
- The request is a card on the board of every Elfcore player of your realm and faction: the item and
  quantity, your guild, who brings the materials, a price reference and your details. It only ever
  says open, taken, cancelled or expired: never who took it, the terms or how it ended.
- A listed crafter who makes it, or for a gathered material a player whose own Herbalism, Mining or
  Skinning skill shows it (read on his client, sent nowhere), sees it marked and hears it once. The
  first claim to reach the requester wins; everything after it (the terms, the delivery, the
  request's chat) is a logged whisper between the two of them, and on the guild-mediated rail with
  the treasury keeper who holds the goods and the gold. Elfcore fills a mail or says what to send:
  you press Trade or Send.
- Once a claim wins, Elfcore opens the request's own chat on both players' Chat tab, with the
  Elfcore window in front. It waits as Elfcore's other windows do: in an instance or Busy until you
  are out (its line waits on the Decrees tab), in a fight until it ends, and while you are typing
  in the Chat tab's box until you send or leave it; by then it opens only if the deal is still
  open. It stays while the deal is open; once the deal is over you may remove it, and the
  request's **Open chat** brings it back.
- **The guild's 6% of a direct sale**: the seller owes the guild 6% of each direct sale made through
  the board, in gold, by 3 days after the sale the buyer confirmed (a sale the buyer never confirmed
  and nobody disputed owes it all the same, 3 days after the delivery the seller recorded or the
  trade both addons saw). He mails it to the guild's fee receiver (the Treasurer's mail character)
  titled "Elfcore craft fee" and the request (his sale's line fills the mail). Late, he is warned and
  takes no new requests until it is paid; a fee mail that comes back is owed again. Both parties'
  addons tell the Treasurer's characters of the sale. The Treasurer, the King, the High Council and
  the author see the debtors, the most overdue first, each with his step on the guild's ladder (late,
  a warning from his guild's Watch, his guild's decision up to removal), and every fee owed; the
  reminders to a debtor are the Treasurer's and the King's. A sale only the buyer reported, or
  a buyer's price above the seller's, waits apart until the Treasurer confirms it. Nothing here
  removes anyone. There is no guarantee fund yet.

### The Missionary Church of Elfcore (1.1.6)

**Guild fullness (1.2.4).** The correspondents' ranking counts the current correspondent's own
management of that guild, not invitation points. Every new appointment starts afresh, including
the same person returning after another correspondent. Only completed server UTC days score:
all admitted native-roster observations must be **above 950**; any observed 950 or fewer breaks
the streak. An unobserved or budget-capped day is **unknown**: no point and no erasure of the
proved streak. Each qualifying day's observations are averaged first, then those daily means
receive equal weight in the streak's tie-break. This is role-authenticated, client-observed
evidence, **not server certification or proof of continuous 24-hour fullness**. Incomplete,
filtered or stale rosters and census totals do not supply observations. The counter reuses
the existing complete native roster cache and its captured server timestamp; it performs no
second 1,000-member scan. Current verified
correspondents send only live own-guild observations privately to a Church keeper; census-only
appointments and retrospective correspondent claims cannot establish a day elsewhere.
Authorized keepers privately relay only retained admitted observations, in requested batches
of at most 150, rotating through the bounded cache. Contiguous same-count observations are
coalesced without changing their count or mean. Seven days of relay evidence, 128 guilds and
20,000 runs at most are retained; older days fold into this client's durable checkpoint for
that exact person and appointment, with at most 32 management checkpoints per guild.
Checkpoints are never accepted from another client: a fresh client without older evidence keeps
that history unknown. A predecessor's proof, a person's former appointment and an old unscoped
guild aggregate cannot score the new management. Ordinary presence with an unchanged appointment
does not reset its own proven streak. No new honour, gold rule or public/general-channel feed is added.

*Continued in the README: [The Missionary Church of Elfcore (1.1.6)](https://github.com/dnl-gentile/elfcore-addon#the-missionary-church-of-elfcore-116).*

### World map
- Soldiers per zone on zone and continent maps, and per continent on the world map (none with
  Blizzard's gamepad mode since 1.1.5: see below).
- Decrees are round icons (the horn, the war cry...) where they were called, and the King's
  crown where he stands; the Board's camps (1.1) one fire badge per zone, with how many. Over a
  zone's circle they move just outside its edge, top right first, so its number stays readable;
  several around one circle each take a place of their own.
- The round **Elfcore** button in the bottom left corner of the map switches markers
  (army per zone, decrees, camps) on and off.
- Every zone of the game counts, not only Azeroth's (1.1): on TBC Anniversary Outland's zones
  get their circles, and Outland's total shows on the map above Azeroth and Outland. A zone a
  new patch adds is found by itself the first time a guildmate stands in it; one the addon still
  can't place shows as plain text in the census, and `/elf status` (and `/elf bug`) lists its
  name under "zones without a map id".

### Elfcore Link: your Discord role (1.0.0, optional)
Prove to the Elfcore bot on Discord that a character is yours, and the bot gives you your role.
It is the one part of Elfcore that goes outside the game, and only if you choose to link a
character (or to confirm other players' links, below): no password, no Battle.net login, and
nothing is sent before you say yes.

Not open yet: the addon carries it, but `/elf discord` says it is not open until the Elfcore bot
is ready and its key is in the addon. Until then no addon makes, keeps, announces or uses a
confirmer key.

1. **Get a code** from the Elfcore bot on Discord (its `/verify` command, in the Elfcore server:
   only you see the reply). It is good for 24 hours. Keep it to yourself, and don't show it (or
   the Elfcore Link window) on a stream.
2. **Type `/elf discord <code>`** in the game's chat. The addon checks the bot's signature on the
   code, then asks whether to link this character to the Discord account the code names (the
   bot's word: nobody can change it). **Cancel** sends nothing.
3. **Players confirm in game**, by addon whisper, that this character asked: a High Councillor
   online, or, when none is, verified players drawn for your code (three of them must confirm).
   Each signs with a key of its own, for its character, which the bot certified. Every confirmer,
   High Councillors included, gets a key from the bot's keeper, made on a computer, and types it
   in the game with `/elf discord key <id> <key>`, then its certificate with
   `/elf discord cert <certificate>`; no addon makes a key of its own (the author's council
   authority, which could certify keys made in game, is off). Once the bot is ready, a
   confirmer's addon says so on the Elfcore channel every 5 minutes and signs other players'
   requests by itself (`/elf discord key off` stops it).
4. **The proof reaches the bot.** The **Elfcore Link** window shows a QR code and the same link
   in a copy box. Open the Elfcore Link page, https://dnl-gentile.github.io/elfcore-addon/ (a
   static page on the project's GitHub Pages): point your phone's camera at the code, share the
   game's window with the page, or paste the link, then sign in with Discord there (Discord's own
   sign-in page, which tells the bot who you are on Discord) and the page sends the proof to the
   bot. Or, later, the addon hands it to a High Councillor's watcher the next time you are both
   online, and the bot's keeper uploads it.

The page reads the code in your browser: the camera and the shared window never leave it, and
the proof rides after the `#` of the link, which a browser never sends to any server. The page
loads its fonts from Google Fonts. The bot keeps which character (name, realm, guild and
faction) is linked to which Discord account, and a record of each proof it received (for 90
days). A linked character never moves to another Discord account by a new link: the bot refuses
it. **Delete my link**, at the foot of the Elfcore Link page (signed in with Discord), takes the
role away and deletes what the bot keeps about your account, except how many codes and links you
used today, counted for a day at most. The Elfcore bot is Fernmelder's; how it checks a proof
is on [GitHub](https://github.com/dnl-gentile/elfcore-addon) (the README and `web/FERN.md`).
`/elf discord show` opens the window again, `/elf discord status` lists every character of your
account, `/elf discord forget` drops this character's request and proof.

### Everywhere
- **Copy**: every tab produces a ready-to-paste text for Discord.
- **Version letters** (1.1.5): after the addon updates, once a version, a short letter on
  parchment, in a window like the Elfcore window's, says what changed in that version, in the
  dev's own words. It waits until the privacy page is closed, and never opens in combat, in a
  dungeon or outside an Elfcore guild. Without saved history the letter stays quiet and unread.
  If the beta forgets saved data, it cannot detect updates; manual history stays available
  without repeat login popups. With retained data, updates can show once. The Elfcore window's help button
  (the **i** left of the X) keeps every letter: **Version letters** on its page lists them,
  newest first, and a click opens one; `/elf letters` (or `/elf letters 1.1.4`) does too. Nothing
  is sent: which letters you saw is kept on your computer, for your account.
- **What this client saw** (1.1, the Decrees tab and `/elf log`): a log of the acts your addon
  took while you were online (decrees, the gates opening and closing, pardons, the King's
  visibility switches for the treasury and the untabarded list, and the shared block terms'
  edits), each with the sender's name as the server stamped it, the newest 300. So "who opened the gates" has an answer after the message
  is gone. Only acts heard from whoever did them: a repeat or a relay of someone else's act (the
  Treasurer's book carrying the King's switches, another editor's list carrying a block term) and
  a state caught up on after a later login are not written. On the King's screen, while the
  council's names are hidden there (his stream), every sender but the King shows cut short, and
  the shared terms' words too, as everywhere on his screen. Kept on your computer only, never
  sent, never in `/elf bug`; a record, not proof (anyone can edit their own saved files). The
  Decrees tab lists it with a search box and a copy; `/elf log [n | word | copy | clear]` in chat.
- **Backup** (1.1): `/elf backup` puts one text in the copy box (keepers also have **Copy a
  backup of your book and settings** on the Treasury tab): this character's book of the treasury
  (its opening, its 500 lines and its sums of all time, each giver's weeks of the dues and each
  week's amount with them; on the Treasurer's characters his mail
  character's book too), the King's switches and keepers on his client or a Steward's, and your
  settings (sound, map, minimap, borders, nameplates, Vox, your chat windows and mutes, the
  players you blocked), and (1.2.4) your own signed halves of the Bones games and duels that count
  (this month's and last month's Bones games, the newest 400, and your newest 200 duels; never
  the other player's: a Bones game's comes back when your addon asks him, a duel's from his
  repeats or the clerk's carousel). Keep it in a text file: when the beta wipes the saved
  variables, `/elf restore` opens a box to paste it back, says what it restores and waits for
  your yes. Clipboard
  only: nothing is uploaded or sent anywhere (a keeper's book goes out afterwards as it always
  does). A book goes back only into that character's (merged with what it wrote since, nothing
  counted twice), a text that was cut or changed is refused, and it never holds your yeses to
  sharing (the addon asks them again). It never holds or sets the channel key, on anyone's
  character: a text someone else made would move your guild to another channel (your officers
  hand the key out in game as ever, or `/elf key`); the confirm says a key in a text is left out,
  and warns when it is one your guild replaced. The players it would block are named one by one
  in the confirm (30 at most) and added only on your yes.
- **Search**: a box on top of the Census (guilds, Lords, Captains, players, zones, recruiting),
  the Realm (guilds, Lords, Captains, members seen online), Crafters (crafter, guild or profession), the
  Tabards (inspected and untabarded players, by name or guild), the Treasury (donors in the
  ranking and the book, and since 1.1 the bank's items), the Decrees (since 1.1: the log of what this client saw) and the Chat tab (since 1.1.1: a name, a guild or words of a line). Any case, accents too; only what matches shows, under the headers it belongs to (a Captain under his guild, opened
  for you, a page of guilds at a time), with an **x** to empty it. Each tab keeps its text until
  you log out or `/reload`; a guild clicked in the Census opens in the Realm with its box emptied.
  It only changes what the list shows: **Copy** still gives everything, and nothing is sent.
- The window opens from `/elf`, the minimap button, or the round button in your guild window:
  the old Guild tab or the new Guild & Communities window, whichever one you use.
  Shift-click the minimap button for the Chat tab (1.1.1, above).
- Next to Forever's Guild & Communities window it takes that window's look: icon tabs down
  the right side, its rows, column headers, buttons and member card. When the tabs do not all fit
  down that side, the canonical tail continues from the bottom of the left edge upward. Reading
  the right top-to-bottom and then the left bottom-to-top always gives the same tab order.
- **Blizzard's gamepad mode** (Forever's controller interface): Elfcore asks its questions in
  windows of its own instead of the game's popups, which Blizzard's gamepad code blocks (and
  freezes) when an addon opens one. With mouse and keyboard, the game's popups as always.
  Since 0.9.8 it also leaves the game's own frames alone there: no quiet `/who` on its own
  (**Refresh** and **Find Elfcore online** still search, and so does the King's click on his
  Throne's /who line for his key rotation, 1.1: the answer shows in the game's
  Who list), and the Issue Reporter is the game's to show. Since 0.9.9 it leaves the world map
  alone there too: no zone counts, decrees, crown or guildmate dots on it (the minimap keeps
  the crown and the dots), because each of those went through the map library into the gamepad
  map's own state; since 1.1.5 its continent totals and Elfcore button go too, the gamepad map
  being the game's alone. If the game still says it blocked
  Elfcore, a `/reload` clears it; to tell us what it was, open the Elfcore window, press its
  help button (left of the X), then **Report a bug**.
  **The gamepad gate (1.1.5).** Every way Elfcore reaches into the game's own windows is listed in
  one place and asks one gate before it acts, so a new feature can't reach them with the gamepad
  UI on by accident. With the gamepad UI on, Elfcore registers no typed command (`/elf`,
  `/elfcore`, `/ef`, `/efc`, `/efl`): the game's chat box runs a command's function and then
  closes itself in that function's name, which is the very call the gamepad UI refuses. Nor does
  it put its round button in the game's guild windows, where the gamepad cursor would select it.
  Open Elfcore with the minimap button (it shows there even when `/elf minimap` hid it), and use
  its window (its help button: **Report a bug**). Switched to the gamepad UI in the middle of a
  session (Options, Gamepad), Elfcore steps back from the game's windows on the next frame: its
  marks, borders and buttons there hide, its tooltip lines and menu lines stop, and what the game
  keeps until a `/reload` (the commands typed with mouse and keyboard among it) is told once, in
  Elfcore's own window, with a **Reload** button. Back to mouse and keyboard, it all comes back
  without a `/reload`.
- English and Portuguese in full, and since 1.1 Spanish, French and German for the main
  screens, the alerts and decrees, the Join screen and its whisper, the chats and the privacy
  questions (the rest in English; the pages' **?** explanations and the Answers of 1.1.2 are in
  English too). It follows the game language, and only the text on your
  screen changes: nothing sent between players does. `/elf status` shows the language in use.

### Other addons: the Elfcore API (1.2.4)

Another addon can read, with your permission, what Elfcore already shows you: the Wanted list
and its bounties, the public rankings (the Slayers, the Church's top three, the games the King
made public, the donors' top three while he shows the Treasury's ranking), your own frame and
title, your Elfcore guild, rank and role, and the King's presence as his lines and the Realm tab
show it (online, the zone they name, his crown while he shares it, whether you are on his layer,
and his zone's layers with their "~N with Elfcore" counts while you are there). The King's
presence, the player-sighting searches and the profile presentation below are reserved for addons
the Elfcore team has authorized; any other addon is asked only about the rest. An addon that asks gets its own line on the privacy
page and nothing until your **Yes** there or the page's deliberate **Authorize all** action
(`/elf privacy` changes it at any time; **Keep current choices** grants nothing). Ordinary reads
send nothing. A compatible addon can also let an authorized player start a short exact-name
last-seen search, maintain a bounded set of exact-name searches while a visible tool session the
player started remains on, or start a five-minute hostile-area search for one selected zone or
micro-map, which may be widened to labelled not-hostile players outside Elfcore guilds (or with
none), never the observer's group. Its visible Start declares selected/configured names and any included list source. A
handle has one area at a time: current map or an owned exact-result map until its row expires, then cancel
and wait 60 seconds to rotate. Its UI shows map/position and Stop/Off; it never opens the map or
resumes after No or `/reload` automatically. Elfcore sends each exact **Name-Realm** sought, or the
selected map ID, to the network.
Members who separately enabled **Guild tools: player sightings** may answer privately from a
current target, nameplate or mouseover observation or one their client kept only in memory after
the game directly showed that player. While that permission and location sharing stay on, each
client keeps at most 64 observations for up to 15 minutes, never saves them, and clears them on
permission, location-sharing or network opt-out. Each observer can contribute at most six hostile
observations to one area search and the requester keeps at most 48 distinct players. An exact-name
answer gives that observer's name and guild; a public area row omits both. If WoW returns a native
point for the visible unit, or the same identity as a party or raid unit, the result carries that
target point. Otherwise it carries the observer's nearby encounter point, rounded to 0.1% of the
map. The kind, observation time, expiry and layer are labelled, so this is last-seen information,
not continuous tracking. Requests and answers expire, and turning either permission off cancels or
withdraws them. On an explicit action the requester can show sanitized area rows with Elfcore-owned
world-map pins; they clear on cancellation, expiry, permission revocation or `/reload`. Elfcore
can also host one bounded profile presentation. A current signed issuer or the addon's author opens it; an admitted
member may enable only Elfcore's fixed style and pre-approved caption on themself. It accepts no target, asset path or arbitrary text,
and **No** closes that addon's state. Elfcore
never gives another addon the census, other players' private data or Elfcore's keys; each addon gets
its own bounded copy. What that addon then does with a copy is up to it, so authorize only addons
you trust. After the update it loads once the game restarts (not on a `/reload`).

*Continued in the README: [Other addons: the Elfcore API (1.2.4)](https://github.com/dnl-gentile/elfcore-addon#other-addons-the-elfcore-api-124).*

## Install

**Easiest:** install **Elfcore Guild** from the CurseForge app or WowUp. It installs in the
right place and keeps it updated. For Forever, pick the Forever (beta) installation of the
game in the app, not Classic Era.

**By hand:**
1. Download `Elfcore-x.y.z.zip` from the **Files** tab here (or [GitHub Releases](https://github.com/dnl-gentile/elfcore-addon/releases)).
2. Open your World of Warcraft folder. On Windows it is usually
   `C:\Program Files (x86)\World of Warcraft\` (on Mac: `/Applications/World of Warcraft/`).
3. Open the folder of the game version you play. For the **Forever beta** it is the one with
   *beta* in its name (for example `_classic_beta_`); Classic Era is `_classic_era_`, TBC
   Anniversary is `_anniversary_`.
4. Go into `Interface\AddOns\` (create `Interface` and `AddOns` if they don't exist) and
   extract the zip there, so you end up with `...\Interface\AddOns\Elfcore\Elfcore.toc`.
   Careful: Windows' *Extract All* adds a folder named after the zip
   (`AddOns\Elfcore-0.8.1\Elfcore\...`). If that happens, move the `Elfcore` folder up into
   `AddOns`; the game only loads it from `AddOns\Elfcore\`.
   From 1.3.3 the zip holds three folders: `Elfcore`, `Elfcore_Arena` (the Blood Arena's screens,
   loaded only when you open the arena) and `ElfcoreSiteAggregate` (the deliberate, no-upload
   website reporter). All three go in `AddOns`, and all three move up if *Extract All* added a
   folder. Keep them together and update them together; both additional folders need Elfcore enabled.
5. **Restart the game.** If the addon list says *out of date*, tick **Load out of date AddOns**.

The addon only shows **live data**: guilds appear as soon as one of their members with the
addon is online (give it a few minutes). There is no demo mode any more.

**One member per guild is enough** for that guild to appear for everyone. The more guilds
have at least one install, the more complete the census gets.

### For officers: seal the channel (recommended)
Type once, with a secret the Elfcore officers agree on:
```
/elf key <secret>
```
Your guildmates with the addon receive it automatically through guild chat. From then on
the Elfcore channel has a name and password derived from the secret, and outsiders can't
find or join it. Share the same secret with the officers of the other Elfcore guilds
(for example in the officers' Discord), so all guilds meet on the same sealed channel.
Since 1.1 the King (or his Steward, for him) can also rotate the army's key from the Throne: his new key reaches the
Lords and Captains online of the guilds he picks whom his own /who saw in them by whisper, and
their guilds over guild chat, never on the Elfcore channel.

If a guild was accidentally given a different private key and lost the shared census and
Elfcore chat, one of its current officers can use `/elf key off`. The recovery instruction stays
inside Blizzard's guild channel, returns updated guildmates to the public Elfcore channel, and
retires the old private key so a delayed message cannot split them again.

## How it works

1. Every guild member can read their own guild's roster: name, level, class, zone, rank,
   online and last seen.
2. Members with the addon find each other through hidden addon messages in guild chat and
   **elect one reporter per guild**. The first name alphabetically wins, and every client
   computes the same answer.
   Each realm of WoW: Forever has a hidden channel of its own, so a guild with members on
   several realms elects one reporter on each realm (since 1.0.0).
3. The reporter sends a compact summary of its guild about every 3 minutes on the hidden Elfcore channel.
4. Every client adds up all the summaries: that is the census.

The addon itself talks only in game, through the game's own addon messages: it has no server of
its own, and nothing it sends leaves the game. One exception is Elfcore Link (above), and
only when you choose to link a character: it uses a website (the Elfcore Link page, on the
project's GitHub Pages) and the Elfcore bot on Discord. A confirmer (a key from the bot's keeper)
signs other players' requests by itself once the bot is ready, and those signatures reach the bot
in their proofs. The other is the Elfcore Companion app, only if you install it (Privacy, below).

**Realms vs layers.** A realm (ClassicBetaPvP, ClassicBetaPvP2...) is a separate world
with its own guilds; layers are copies of a zone *inside* one realm. Guilds on the same
realm always see each other, whatever layer they are on. The hidden channel stays inside
one realm (PvP and PvP 2 each have their own), while guild chat reaches a guild's members on
both. So since 1.0.0 each realm elects its own reporter for a guild, and the High Council's
lists cross over through guild chat. Realms whose guilds span each other share one
census and one realm key: PvP and PvP 2 on the beta from the start, and any realm your
guild turns out to be homed on. Alts on any other realm keep their census apart, and the
window shows which realms you are counting.

## Privacy

The addon itself talks only through the game's own addon messages: it has no server of its own,
and what it sends stays in the game. One exception is Elfcore Link, and only when you choose
to link a character, or to confirm other players' links: a link's proof goes to the Elfcore bot
on Discord, through the Elfcore Link page on GitHub Pages (where you sign in with Discord) or a
High Councillor's watcher. A confirmer, a High Councillor too, is someone who typed in a key the
bot's keeper made them (no addon makes or announces a key by itself, and the author's council
authority is off): once the bot is ready, their addon says so on the Elfcore channel every 5
minutes and signs other players' requests by itself, and their character's name and signature
reach the bot in those players' proofs, until `/elf discord key off`. The other is the Elfcore
Companion app, only if you install it: its own bridge addon takes your character's name and
BattleTag and the Elfcore and guild chat lines your client shows to Elfcore's server, for its staff
alone (the Companion's rows below). Your name is on every message (the game adds it). What goes where:

*The table is in the README, with the rest of this section: [Privacy](https://github.com/dnl-gentile/elfcore-addon#privacy).*

## Security and trust

**What the author's character can see.** The author (Faladoriel Skylance) has a Workshop tab
to keep the addon healthy. It reads the install counts every guild report already carries,
plus the addon versions of each guild's users. On demand he can ask for a roll call: each
addon online (a share of them when the army is large) answers, by addon whisper to him only,
with its version, game client, and whether it joined the channel, is its guild's reporter and
has the channel sealed with a key. Nothing about the character (no guild, level or class), no
position, no chat, nothing else. He may ask one player alone the same way, by addon whisper:
the same answer, and each addon answers him once every 4 minutes at most, however he asks.
He can also ask a player on an old version to update: a fixed window with the two version
numbers and nothing else. Only his character on his realm group
can do either: every addon checks the sender's name, which nobody else can carry. Since 1.1
a roll call is answered only after the player's yes (the first-open page, or `/elf rollcall on`),
and `/elf rollcall off` refuses both. Since 1.1 your addon also reads the released version his addon
announces on the channel (his presence): newer than yours, the Census, `/elf status` and one chat
line a session tell you to update. That is local to your client, sends nothing, and shows
whatever `/elf rollcall` says. He runs a new build on his own PC before it is published, so his
presence names only the version he marked as out with `/elf released [version]` (his character
only; the Workshop tab shows it) once CurseForge lists it, never the build he runs, and never one
newer than that build; addons before 1.1 read none of it. The addon's error catcher keeps only Elfcore's own errors (for
`/elf bug`), never another addon's. For the store's screenshots he has a photo mode (`/elf
photo`, his character only): on his own screen it fades everything but Elfcore and the world
map to invisible, and gives every frame its look back on the second `/elf photo` or a
`/reload`. Never in combat, not with the gamepad UI, not on a screen of more than 1000 frames
(it says so and leaves them as they are), and nothing is sent to anyone.
To check the elite borders his own rank doesn't carry, `/elf borders test <tier>` (his
character only) shows one of the borders round his own portrait, and on his target frame when he
targets himself, and its nameplate mark after his own name on his player frame and on every
friendly player's nameplate (`/elf borders test member`: the member's star alone), on his screen
alone until `/elf borders test off` or a `/reload`. It follows the borders' and the marks' own
rules (none with the gamepad UI, made out of combat), and nothing is sent.

The addon is plain Lua running on each player's computer, so anyone can edit their own
copy. No addon can prevent that. What this one does is check what every copy sends; what a
few characters working together can still reach is said plainly further down
([What colluding characters can reach](#what-colluding-characters-can-reach)):

*The list is in the README, with the rest of this section: [Security and trust](https://github.com/dnl-gentile/elfcore-addon#security-and-trust).*

### What colluding characters can reach

Votes are counted per sender name, and nothing the server tells an addon proves which guild a
sender belongs to: a census report is its sender's word. So a few characters working together
can still reach the following today (1.0.0); each outcome was checked against this version's
code.

*The list is in the README, with the rest of this section: [What colluding characters can reach](https://github.com/dnl-gentile/elfcore-addon#what-colluding-characters-can-reach).*

## Built for a crowd of thousands

- One summary per guild about every 3 minutes, not one per player.
- In a full guild only the members who could be elected keep saying hello; the rest go quiet.
- Layers are announced by officers plus a stable 1 in 8 sample who share them, every 10 minutes
  (the King's alone every minute, while his crown shows: one client, one message a minute).
- A layer request goes out once; only about 6 players answer it, each by a whisper to the asker.
- Messages are spaced 1.2 s apart, below Blizzard's addon message limits, and alert sounds
  play at most once every 15 seconds (1.1: a softer one never silences the Call to Arms or a
  louder alert after it).
- Chat has its own short lane: a line goes out within about a second, and while reports are
  waiting it never takes more than every other message slot.
- The Board (1.1): a flag is repeated every 10 to 30 minutes (less often the fuller the Board),
  and a Board's ask is answered by whisper, by about 40 flag holders at most.

## Commands

| Command | |
|---|---|
| `/elf` | open or close the window |
| `/elf realm` · `/elf decrees` · `/elf tabard` | open a tab |
| `/elf loot` | your guild's loot notes and points on the Realm tab (its officers write them; not a bid window) |
| `/elf craft [item or name]` · `/elf crafter on\|off` | who can make it (the top-level Crafters tab: shift-click an item after `/elf craft`); list your professions read so far, or take them off |
| `/ef <text>` · `/efc <text>` · `/efl <text>` | write in [Elfcore], [Captains] or [Lords]; alone (`/ef`, `/efc`, `/efl`): open the Chat tab on that channel (1.1.1) |
| `/elf mute elfcore` · `/elf mute captains` · `/elf mute lords` | hide or show a channel in chat |
| `/elf chatwindow tab` · `/elf chatwindow <number or name> [elfcore\|captains\|lords]` · `/elf chatwindow main` | the Elfcore chats in a chat tab named Elfcore (without the channel's name; it says how to make the tab), in another chat window (with Chattynator, one of its tabs, by name), or back in the main one |
| `/elf privacy` | the first-open page again: what the addon shares, and your Yes or No to each (1.1) |
| `/elf chat on\|off` | the Elfcore chats on this client; off, nothing is sent or shown (1.1: off until you say yes) |
| `/elf talk [elfcore\|captains\|lords]` | open or close the Elfcore window on its Chat tab, on that channel; also `/ef`, `/efc` or `/efl` with nothing after it, or Shift-click the minimap button (1.1.1) |
| `/elf helpme [text]` (or **Ask a High Councillor** on the Realm tab) | ask the High Council (the moderators) for help: it goes by whisper to up to three of them online who take requests |
| `/elf discord <code>` · `/elf discord` | Elfcore Link: link this character to your Discord account with the bot's code (or paste it in a box) |
| `/elf hop` | ask for an invite to the King's layer (while he is online) |
| `/elf lfg` · `/elf lfg dungeon\|raid\|pvp\|layer [note]` · `/elf lfg off` | the Board (1.1): who is looking for a group; raise your flag (a box with your note first) or lower it |
| `/elf week` | the week on the Board and Decrees: army and own-guild Agenda entries for 7 days, alongside your guild's calendar; eligible schedulers see separate army and guild buttons ("Sat 20:00 Raid night") |
| `/elf location on` · `/elf location off` | share (or not) your zone and layer on the Elfcore channel |
| `/elf borders on` · `/elf borders off` | elite borders round the portrait of your target, focus, party members and your own frame (Forever): the game's gold wings for the King, silver wings for the High Council and Max's bronze wings for Elfcore guild masters (none for a character or guild the moderators took off, net-off). Legates and correspondents use separate verified office shields instead of the old wingless bronze role frame; signed High Council departments use the same shield family without replacing silver, and earned honours remain. Since 1.1.5 the old rank borders (gold for Lords, silver for Captains, bronze for Raiders and Veterans) are gone, and any other member has the nameplate star alone. On by default, hidden with the gamepad UI. Off, the nameplate marks go too |
| `/elf nameplates on` · `/elf nameplates off` | a small mark left of the name on friendly players' nameplates (Forever; friendly nameplates show with Shift+V): the game's gold elite mark for the King, silver for the High Council, bronze for guild masters, the verified Legate or department shield for an appointee, and a star for any other member of an Elfcore guild (none for a character or a guild the moderators took off, net-off); on by default, hidden with the gamepad UI and with `/elf borders off` |
| `/elf chatmarks on` · `/elf chatmarks off` | 1.1.5: the verified mark before a player's name in the game's own chat (channels, say, yell, emote, party, raid, instance and whispers; guild and officer chat the office marks alone, never the star): the King's gold dragon, a High Councillor's silver then their icon, a guild master's bronze, the Legate or department shield for an appointee, and the star for any other member your addon can check. Elfcore's own lines carry none. Through the game's own name filter, so the name's link, right-click and /r stay the game's; on by default, hidden with the gamepad UI, and a councillor's on the King's screen while the council's names are hidden |
| `/elf block <name>` | ignore a player |
| `/elf filter add\|remove <word>` · `/elf filter` | block terms: hide, on your screen, lines of addon text (Elfcore chats, writs, decrees, Vox) with a word; the list (1.1) |
| `/elf alt add Name` · `/elf alt remove Name` · `/elf alt` | link a character of this account as your alt (log it and say yes there), take a link apart, or see your links: the census and the treasury count you once (1.1) |
| `/elf sound` · `/elf sound on\|off` | every alert sound on or off |
| `/elf bug` | copyable bug report (also: the help button left of the window's X, then **Report a bug**) |
| `/elf status` | diagnostics in chat (1.0.0: whom your addon knows as the King's Steward, and the lists of Hands it holds, whose each is; 1.1.2: the author's in a copy window) |

*Every command in the README: [Commands](https://github.com/dnl-gentile/elfcore-addon#commands).*

## Reporting a bug

While the addon's author is online, the **Report a bug** window also has a **Send to
Faladoriel Skylance** button: your report goes to him in game, by addon whisper, and nowhere
else (once every 10 minutes at most, unless he asked for it). It first checks he is really there: the rest follows
only once he answers, and you are told when he got it.

Since 1.1.2 the author can also ask you for it from the right-click menu: your addon shows you
the exact text first, in a window of its own, and sends nothing without your **Send**.

Type `/elf bug` (or press **Report a bug**), copy the text and open an issue on [GitHub](https://github.com/dnl-gentile/elfcore-addon/issues). Errors are
also saved in `WTF/Account/<ACCOUNT>/SavedVariables/Elfcore.lua`.

## Credits

- **Asmongold** and his team (Daily Dose of Asmongold, Max, Heuto, Fernmelder and the High
  Council), for making Elfcore the army's addon and for the ideas.
- **Security reviews:** Konig, bjess9 (jess), lordjumper and Fadirstave, who read the code and
  showed what an attacker could do.
- **Code and ideas:** RoyLeviGit (Elfcore chats in their own chat window), Artz (hiding the
  Issue Reporter), bjess9 (CI and the shared checks), hypertectonic (Chattynator's tabs),
  Bernardo Costa / Costafitness (exact layer-hop confirmation and stale-request regressions,
  adapted from PR #51), and Rick-laboratory (bounded transport, cancellation and admission
  regressions, adapted from PR #52).
- **Feature requests:** Fernmelder, whose 39 posts became 1.1 (the Fernmelder release);
  shenanigans_ (the nameplate marks), Valdericht (`<ELF>`), Pyralis Ashandar (taking
  donations) and Zeal (what the King hides stays off the channel).
- **Art:** Max (the bronze elite borders, drawn over the game's own; the winged one remains the guild masters').
- **Reports from the field:** Riukensei and PartyRockAce (the gamepad UI; PartyRockAce's report
  of the world map blocked in controller mode, fixed in 1.0), Ignitheus (whispers to Forever
  names), Pyralis Ashandar, the Treasurer (the treasury and the guild bank), and the player who
  told us WoW had handed him the channel.
- Everyone who reported a bug, tested in game or asked for a feature.

## License

MIT. Not made or endorsed by Blizzard Entertainment. The Elfcore emblem belongs to its owners
and is used for the community.

*Sources for the Elfcore description: the Elfcore Discord welcome message,
[Prism on X](https://x.com/fwprism/status/2101809316382847172) (10K+ members in the beta),
[Dexerto](https://www.dexerto.com/world-of-warcraft/asmongold-responds-as-wow-forever-players-want-him-banned-over-massive-elfcore-guild-3411199/).*


Source code: https://github.com/dnl-gentile/elfcore-addon
