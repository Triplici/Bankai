# Bankai Guild

**The whole Bankai Guild army in one window, inside World of Warcraft: Forever.**

Bankai Guild is Shobek's guild for *World of Warcraft: Forever*: Alliance, PvP ruleset, a
place to find dungeon groups, organize raids, share class knowledge and build the guild
together. It grew past **10,000 members during the beta**. A WoW guild caps at 1,000
members, so Bankai Guild is really a *realm* of many Bankai Guild guilds. In game each player
only ever sees the roster of their own guild. Nobody could tell how many Bankai Guild guilds
exist, who leads them, or where the army is.

This addon answers exactly that. It adds up every Bankai Guild guild live, in a window that
looks like Blizzard's Guild window and docks right next to it.

![The whole army at a glance: every Bankai Guild guild, live](https://raw.githubusercontent.com/dnl-gentile/bankai-addon/main/docs/bankai-1.jpg)

![Where the army stands: soldiers per zone on the world map](https://raw.githubusercontent.com/dnl-gentile/bankai-addon/main/docs/bankai-5.jpg)

> **Status:** built for WoW: Forever and running on the Forever beta (1.60.1), where the
> census already adds up reports from many Bankai Guild guilds. Also tested on Classic Era (1.15)
> and Anniversary (2.5). Please report anything that looks wrong (`/bk bug`).

---

**Horde too.** Bankai Guild guilds on the Horde side use the same addon. The factions can't see
each other's guilds, so each one gets its own census, channels, decrees and untabarded list: the
addon picks yours from your character. On the Horde, the Crown is every Horde Bankai Guild guild
master and the officers of the Horde guild named exactly "Bankai Guild", if there is one.

## Recent versions

- **1.4.1**: Olympus 1.4.1 merged in: the army's channel moves to the next lane by itself when the game refuses
  it; the Board's group finder; Italian and Russian, fuller German, Spanish and French; Bankai Guild Link
  as its own addon; newer game clients. Every module's TOC depends on BankaiGuild (it named "Bankai Guild").
- **1.3.3**: Deliberate site export: an optional Site Aggregate folder writes a masked own-guild count for the
  Bankai Guild website on /bk site export and /reload, never uploads, and empties at the next logout or reload.
- **1.3.2**: Correction: explicitly approximate Census people counts, preserve accepted Treasury rows,
  fix full-suite ordering regressions and export consented Companion identity evidence.

Every version's notes are in the [GitHub releases](https://github.com/dnl-gentile/bankai-addon/releases). This page is the short one for CurseForge: the [README](https://github.com/dnl-gentile/bankai-addon#bankaiguild) has every section in full.

## Who can use it

**Only members of a guild with "Bankai Guild" in its name**, however it was spelled: OLYMPVS the Roman way, Olimpus, Olmps, Olympuz, Olympos, Olimpo and other misspellings count too (Olympia or Olympic do not), and a guild against Bankai Guild ("ANTI Bankai Guild", "Bankai Guild Haters") does not. The check is fixed in the code and
cannot be switched off with a command. Outside an Bankai Guild guild the addon joins no channel
and hears nothing of the army, but for the author's signed list below, over its own guild.
The only thing it offers there is the **Join Bankai Guild**
screen described below, and its own few addon whispers are the only ones it sends or hears
there (1.1: which guild to ask, the answer, and your request, each to or from the one member
concerned). Using it requires accepting its terms, the Bankai Guild Accord, which shares your BattleTag with Bankai Guild's staff only.

**Approved guilds (1.1).** A guild of Shobek's Bankai Guild whose name the rule leaves out (it leaves
Olympian and Olympia out on purpose) counts as an Bankai Guild guild once the author names it in his
signed list: the same list, signed with the same key on his own computer, that names the High
Council and the Shogun's Steward, for one faction and realm group. No census vote counts, and nobody
else can add one. A few ship with the addon itself, so their members have nothing to paste: since
1.1, the Alliance's `<ELF>`, and since 1.1.5 its `<ELVES>` too (only a new version takes one of those off). Its members' addons, no Bankai Guild members
until they hold that list, take it over their own guild alone (the list only: nothing else is
read, and they send nothing). The first of them pastes it with `/bk approved paste`, or a click
on the Join Bankai Guild screen's last line (the author
or a High Councillor hands out the signed text; it is checked like any list, so it can't be forged
or changed), and his addon passes it to his guild every 5 minutes. `/bk approved` lists the
approved guilds of your faction. A newer signed list without a guild ends it on every client.

**Removed guilds (1.1.5).** A guild the High Council removed from Bankai Guild is no Bankai Guild guild,
whatever its name: its census, chats and marks are gone and its members' addon shows the Join
Bankai Guild screen. Its way back is an appeal to the council: once the author names it in his signed
approved list, it counts again, with no new version. Until a player updates, the council's
[net-off](#net-off-11-the-moderators-hide-a-character-or-take-a-guild-off-the-network) word takes
such a guild off the network live.

### Not in Bankai Guild yet?
First it asks the obvious question: *"<Your Guild>? Disband immediately. What are you
doing?"* Then it helps you get in. The **Join Bankai Guild** screen uses the game's own `/who` to
find Bankai Guild members online, groups them by guild, and whispers one of them a ready-made
request that you can edit ("Hi! I'd love to join Bankai Guild. Does <Bankai Guild II> have room for
one more?"). No answer? **Try someone else** picks a member you have not asked yet. Replies
are highlighted. It is rate limited, so nobody gets spammed.

**Where to go** (1.1): a search also asks one member's addon (an addon whisper, not a chat line)
where recruits should go, and its census answers: the guild the Shogun opened **the gates** of
first, then the guilds with the **most free slots**, and a couple of their Elders and Council
online (never the Shogun). It names only what the census confirms: guilds two members' reports
agree on, and Elders and Council two reports name. The screen lists them in that order, each
once `/who` found one of its members (the gates once a second member's answer agrees: one more
is asked), the guilds found with `/who` too, and a click asks one of those officers that `/who`
found in that guild, or another member it found there. Just before, their addon is asked
whether they take recruit whispers (again if it never answered): a member who set **do not
contact** (`/bk nocontact on`) is never offered, however many recruits ask him, and the
question closes before anything is sent. It stays **one whisper per click**, in your
own words (no dues line), 20 seconds apart. With it goes your request to the same member, so an
officer's addon shows it with **Invite** and **Decline** instead of a raw whisper. Members on
versions before 1.1 just get the whisper, as before.

## What it does

### Census: the army at a glance
- Every Bankai Guild guild in one list: **Guild · Members · Online · Avg lvl · Elder**. Columns sort by
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
- **An update line** (1.1): when the author's own addon says on the Bankai Guild channel that a newer
  version than yours is out (he marks it once CurseForge lists it, never a build he is still
  trying), a line at the foot of the Census, one line in chat once a session and `/bk status`
  say so. It is yours alone: nothing is sent and nobody is whispered.
- **Marked rows** (1.1): a warning mark on a guild whose senders disagree (on its Elder or
  Council, or on its size, by more than 5 members or 5% plus the 20 a minute a guild may gain or
  lose between their two reports), a question mark on one that a single
  sender stands behind. Its tooltip says which and who: check before calling a muster or opening
  the gates on it (the gates ask again, with the reason). A marked row can still be right, and
  the mark changes nothing that counts. Your own guild (your roster) is never marked.
- **Asking to join** (1.1): a recruit who asked you from the Join Bankai Guild screen shows on top of
  the Census, with their whisper. An officer (the game's guild invite permission) answers with
  **Invite** (the game's own guild invite) or **Decline** (one whisper pointing to the gates'
  guild while the Shogun's gates are open, else naming your guild alone: never a guild the census
  lists for its room, which two made-up characters could report), one click each; anyone else
  can point them to an officer online. **Dismiss** sends nothing. In the Realm's Recruiting, one
  click (or `/bk nocontact`) sets your **do not contact** flag.
- **Search the census** (1.1): a guild, an Elder, a Council member, a player of a guild's top five or one
  seen online (the player shows under the guild's row), or a zone ("Stormwind": its soldiers
  and its guilds, most first). Type **recruiting** (or `free 50`) for every guild with room,
  most free slots first and the Shogun's gates on top.
- **Tonight on this client** (1.1): under the list, the most soldiers your addon saw online at
  once tonight and when, and (in its tooltip, and next to a zone you search) how each zone
  filled or emptied since. Counted by your own addon once a minute from the reports it
  already holds, starting about 3 minutes after login once the census is rebuilt: another
  player's client counts its own evening, and nothing is sent.

### The Realm: the hierarchy
- **War Room**: members read their guild's records; its officers and verified War roles manage them.
  No cross-guild writes. Empty lists explain what is missing; role previews cannot act.
- The **Shogun**, then every guild's **Elder** (guild master) and **Council** (the officer rank
  right below the guild master).
  Each shows level, class and online or *offline 3d*. Long absences show in red
  (`/bk warndays <days>`, 3 by default). **An Elder away** (1.1): when an Elder crosses that, one
  chat line, once per absence: to his own guild's officers from their roster, and to the Shogun,
  his Steward and his Hands for every guild's Elder, by the census's word (a guild that stopped
  reporting included, counted from its last report even when that showed him online). Never a
  popup, and nothing is done to anyone.
- The **Treasurer of Bankai Guild** (Pyralis Ashandar, chosen by Shobek's chat) right under
  the Shogun, with a gold coin next to his name wherever he shows, his tooltip and his lines in
  the Bankai Guild chats included. Only
  that exact character of the guild Bankai Guild gets it: look-alikes don't.
- **Members online** under each guild: your own guild's from your roster, any other's from
  `/who`. Opening a guild searches `/who` for that guild alone (up to 50 of its players).
  Click a name to whisper, invite or `/who` them.
- The **ranks** of each guild with how many members hold them.
- **Inactive members**: offline 7+ and 30+ days, per guild. Your own guild's line (or
  `/bk inactive`) opens the list by name (1.1): members offline 7, 14 or 30 days and more,
  with rank, class, level and last online, from your own roster, longest away first. A rank
  that may remove members (as in the game's Guild window: ranks below yours) removes **one
  person per click**, after a question that shows their rank and days away, a few seconds
  apart. There is no kick-all, and nothing is sent.
- **Mentors** (1.1): an Elder opens **Recruits and their mentors** on that page (or `/bk recruits`):
  his guild's lowest rank and whoever joined since he logged in. He clicks a recruit who is
  online, then one of his Council, and says yes: **one whisper to each** from that click, the
  Council member told who to look after, the recruit told who to ask. The pair shows on his list (his
  client's alone); nothing goes on the channel.
- **Legates and correspondents** (1.1.5): a guild master of an Bankai Guild guild (not the Shogun's)
  has a tab of his own in the Throne's place, **Guild** (or `/bk nominees`), laid out as the
  Shogun's Hands page: **+ Name a legate** (his target, or a name he types), his list (a click
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
  His own client sends the list on the Bankai Guild channel; every addon takes it from that guild's
  master alone (proven as for his bronze wings: your roster for your own guild, two census senders
  for another), retains accepted bounded lists across logouts and offline periods, and drops the
  duty when a verified removal or change of guild master is seen. `/bk nominees legate <name>`
  (the old `centurion` spelling remains an alias), `/bk nominees correspondent
  <department number> <name>` and `/bk nominees remove <name>` do it in chat.
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
  When the Shogun opens **the gates** of a guild, it tops the list: send new recruits there.
- **Layers** of your zone, named after the highest ranked Bankai Guild member on each one
  ("Shobek's layer"), with how many members are there.

### Layer hop: join the Shogun's layer without begging in chat
While Shobek is online, the top of the Census and the Realm shows **"Ask invite for Shobek
Layer"** with his crown. One click (or `/bk hop`) and the addon does the asking:

- You must already be in his zone (a layer is read per zone): if you are not, the line says
  where he is and nothing is asked.
- It asks the Bankai Guild players on his layer who can invite (alone, or leading a group with a
  free seat). Only a handful answer, picked at random on each player's side, so a crowd of
  askers is spread over many players instead of flooding one.
- It picks one of them, favouring players outside a group and with fewer recent invites. They
  get **"X wants to join your layer"** with **Invite**, **Not now** and **Always invite**. No
  answer or a no, and the next one is asked. **Always invite** invites the next ones without
  the window while that player is alone or with only the addon's hop guests; clicked while they
  lead a party or raid of their own, it also covers that group until it ends (1.1.5, GitHub
  issue #50: the window came back with every request there). That group's permission is never
  saved: a later group asks first again, after a `/reload` the window asks once more, and
  `/bk layerauto off` ends it at once.
- The invite is accepted for you when that player is one the addon can vouch for (a member of
  your own guild, the Shogun, his Steward or Hands, or, once the author's signed list is on, an Elder
  or Council member of `<Elfcore>` it names; never a census rank); anyone else's, and every invite
  while Blizzard's gamepad UI is on, waits for your click in the game's own invite window. The
  game moves you to the layer, and the addon takes you out of the group as soon as it sees the
  move (or offers a **Leave group** button if it can't tell).

Players alone on the Shogun's layer are asked once per login: **"Shobek is online and you are on
his layer. May the addon invite the players who want to join, and take them out of the group
once they are there?"** with **For Bankai Guild!**, **Can't right now** and **Invite manually**, and
a **Don't ask me again** box. With For Bankai Guild! the addon invites on its own (only while you
are alone or with its guests, never into a group of your friends) and lets each guest go after
90 seconds: the guest's addon leaves the group, since only a click may remove someone.

*Continued in the README: [Layer hop: join the Shogun's layer without begging in chat](https://github.com/dnl-gentile/bankai-addon#layer-hop-join-the-shoguns-layer-without-begging-in-chat).*

### Person details
Click any Elder, Council member, racer or inspected player. Their profile opens in the Bankai Guild window, at
its size, with the census facts Bankai Guild knows: level, class, zone, rank and status. **Back**
returns to the same list or Realm subpage, one opened from another first; **Whisper**,
**Invite** and **Who** stay on it (offline: **Who** alone). It is not the Blood Arena
companion's profile, and opening it sends no query. `/bk profile Name` (or `Name-Realm`) opens
one by name. Yours is **My profile** (1.2.4: `/bk profile`, the Realm, the Games tab, the Games
window's **Edit my profile**): **Look** (frame, title, nickname, emblem; one not released yet in
grey), **Icons**, **Who sees what**, **Letters** (the Shogun's), and you as others see you.
Any soldier can reach the Elder of another Bankai Guild guild in two clicks.

*Continued in the README: [Person details](https://github.com/dnl-gentile/bankai-addon#person-details).*

### Right-click a player (1.1.2)
Right-click a player (the target frame, party and raid frames, a name in chat, the Who list, the
friends list, a community roster) and the game's menu gets an **Bankai Guild** part at the bottom:
- **Their version**: "Bankai Guild 1.1.1 (out of date)", "up to date" or "not seen yet", and under it
  where it came from and when. Guildmates show up by themselves (their addon says hello to your
  guild), and so does a known version on the person card. Opening the menu sends nothing.
- **Check version**: for anyone else, one tiny addon whisper that their addon answers with its
  version and nothing else (a player once every 2 minutes, 6 a minute). Only 1.1.2 and newer
  answer, so no answer in 10 seconds can mean no Bankai Guild, an older one, a dungeon or raid, or no
  Bankai Guild guild (outside one the addon sends nothing). The author's check is his roll call to that
  player alone, which every version since 0.9.9 answers, and only after their yes to his roll calls.
- **Ask to update** (1.2.1: the author, the Shogun and the High Council only; others' asks are
  dropped), when they are behind the newest version your addon knows: nothing goes before you
  confirm. On 1.1.2 or newer their addon shows a compact notice with both versions and where to
  update; **Read update** opens a plain-language parchment letter: reviewed public release notes
  and the safe next step. For an older one, confirming opens a whisper you send with the ask. One
  ask per player a day, 5 an hour;
  they see one a day at most, **Don't remind me** hides them for 7 days (on the beta, which forgets
  addon data at login, these last until you log out), and a player they block (`/bk block`) or
  ignore, or one the moderators took off, never gets through. The notice never names a version the
  author has not released. The author's pick sends his usual update window, naming the version he
  marked as out (`/bk released`).
- **Tell them about Bankai Guild**, when their addon did not answer: a whisper with a short invite and
  the CurseForge link (to get it, or update an old one) opens in Bankai Guild's own window, for you to
  edit and send yourself. The click sends nothing.
- **Ask for a bug report** (the author alone, on a player running 1.1.2 or newer): their addon
  opens a window of its own, never a game popup, saying the author asks for their Bankai Guild bug
  report, with **See what is sent** (the exact text, the same as `/bk bug`), **Send** and **Not
  now**. Send goes to him alone, in game; Not now sends nothing; an ask from anyone else is
  ignored. On his side the report he asked for opens by itself in a window you can copy from (the
  sender and time on top, **Select all**), and stays in the Workshop's list; chat gets one short
  line. A report nobody asked for gets its line and the list only. Since 1.1.5 his addon keeps the
  last 30 reports in its saved variables: where the game loads those back, a logout or a `/reload`
  loses none, and his list opens them in the same window, the date on top for one from an earlier
  day. The Forever beta, which forgets addon data at every login, still loses them at each logout
  or `/reload`. No other player's addon keeps any, and the Workshop's copy for Discord says only
  how many came, never who sent them or what they say. His version checks and his
  `/bk status` open in copy windows too. A window that opens by itself takes no keyboard, waits
  until a fight is over, and never covers a report he is reading.
- In a dungeon, a raid or a match the game holds addon messages: the lines that send show greyed
  and say why. Not on yourself, enemies, offline names or Battle.net friends, and only while you
  are in an Bankai Guild guild. It uses the game's own way for addons to add to its menus (a client
  without it gets no lines); no Blizzard function is replaced, and nothing opens the game's chat
  box.

*Continued in the README: [Right-click a player (1.1.2)](https://github.com/dnl-gentile/bankai-addon#right-click-a-player-112).*

### Decrees
| Decree | Who | What happens |
|---|---|---|
| **Call to arms!** | The Crown, the High Council, the Shogun's Hands | Alarm for every Bankai Guild guild: raid warning, sound, red marker at the caller's position for 5 min |
| **Muster here** | The Crown, the High Council, the Shogun's Hands | Rally point: horn marker on the map for 15 min, soft alert |
| **Royal decree** | The Crown, the High Council | A proclamation with free text, as a raid warning to the whole army; its marker stays 30 min |
| **Tabard inspection** | The Crown, the High Council | Announces an inspection at the caller's position: wear your colors |

*Continued in the README: [Decrees](https://github.com/dnl-gentile/bankai-addon#decrees).*

### Channels
Chat for the whole federation, carried by the addon over its hidden Bankai Guild channel (no
WoW channel number to join). Each channel is exclusive to a rank:

| Channel | Command | Who reads and writes |
|---|---|---|
| **[Bankai Guild]** | `/bg <text>` | every member of every Bankai Guild guild |
| **[Council]** | `/bgc <text>` | the Council (rank 1) and Elders of every Bankai Guild guild |

*Continued in the README: [Channels](https://github.com/dnl-gentile/bankai-addon#channels).*

### The Chat tab (1.1.1)
The Bankai Guild chats in a tab of the Bankai Guild window, **Chat**, right after the Realm, like the chat
pane of the Guild & Communities window. Click the tab, type `/bk talk` (or `/bg` or `/bgc`
with nothing after it), or Shift-click the minimap button: each opens the Bankai Guild window
on its Chat tab, on that channel; the same command again closes the window.
When the side column of the new look runs out of room, its canonical tail continues from the
bottom of the window's left edge upward. Reading the right top-to-bottom and then the left
bottom-to-top always gives the same tab order; changing role or debug view never rearranges it.

*Continued in the README: [The Chat tab (1.1.1)](https://github.com/dnl-gentile/bankai-addon#the-chat-tab-111).*

#### Role rooms (1.2.4)
**Roles**, after Guild: the rooms of the roles you hold, each line a logged whisper to each member.

*Continued in the README: [Role rooms (1.2.4)](https://github.com/dnl-gentile/bankai-addon#role-rooms-124).*

### The Board: who is looking for a group, and where (1.1)
The Realm tab links **the Board** (or `/bk lfg`): who in Bankai Guild wants a group right now, from
what each player chose to share, and the Shogun's week.

- **The Shogun's week** (`/bk week`): the Shogun's Agenda for the next 7 days, by day, with your own
  guild's events from the game's calendar among them, so nobody books the army twice. Bankai Guild
  can't write into the game's calendar: an officer's click opens it on the right day's month and
  says which day to right-click for the guild event. Your client keeps the week across a
  `/reload` or a login, so it shows while the Shogun is offline.
  **Heraldry and guild agendas (1.2.4).** The signed High Council's Heraldry holders and the author
  also schedule for Bankai Guild, alongside the Shogun's existing verified Steward and Hands. **Schedule
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
  class and guild, the flag and the note, to every Bankai Guild player of your realm and faction.
  The note goes the way chat does (the game's servers keep it, so abuse can be reported); on the
  Shogun's screen no note shows.
- **Your zone shows on your card only while you share it** (`/bk location on`); otherwise the
  card says the zone is hidden. Never your position.
- **A click on someone's card whispers them.** Nothing invites anyone, queues or forms a group.
- One flag each, an hour at most; a click on yours, or `/bk lfg off`, lowers it at once.
- **Camps**: drop one where you stand (`/bk camp [note]`) so the army reuses a fire already up.
  Its zone only, never your spot; it needs `/bk location on` and ends by itself after 30
  minutes. The Board lists them by zone, and the world map shows one badge per zone with how
  many (mouse and keyboard only; `/bk camps off` hides them). **Bones can be played at a tavern
  or at a camp** (1.1.6): grouped, within about 10 yards, at the same inn or by your camp.

### Net-off (1.1): the moderators hide a character or take a guild off the network
The Shogun, his Steward, a Hand (the Shogun's list or a Steward's) or a High Councillor of the
author's signed list can hide one character for the whole army: **Hide a character** on the
**Decrees** tab (the name or your target, then the reason), or `/bk netoff Name: reason`. Every
addon then hides that character on every Bankai Guild surface: their [Bankai Guild], [Council] and
[Elders] lines (and the lines the Bankai Guild chats kept), their pinned line, their decrees, their layer and hop offers,
their Poll votes and questions, their requests at court, and (1.1, Konig's review) their
signups to the Shogun's week, their flags and camps on the Board (the camps' map badges too),
their listing, answers and recipe lists as a crafter, and their elite border and nameplate mark
(they show as no Bankai Guild player). The names their player already linked as alts are hidden with
them (alt links, below). The rest of their guild, and
the census, are not touched: one name stops the spam.

*Continued in the README: [Net-off (1.1): the moderators hide a character or take a guild off the network](https://github.com/dnl-gentile/bankai-addon#net-off-11-the-moderators-hide-a-character-or-take-a-guild-off-the-network).*

### Alt links (1.1): one player, counted once
One player in three guilds used to swell the army by three and look like three donors. Link your
alts and the census counts people:

*The list is in the README, with the rest of this section: [Alt links (1.1): one player, counted once](https://github.com/dnl-gentile/bankai-addon#alt-links-11-one-player-counted-once).*

### The Throne (the Shogun and his Hands)
A tab with a crown that only the Shogun sees: the guild master of the guild named exactly
"Bankai Guild" (of his faction), and on the Alliance that very character, Shobek Shobekler: the
addon knows him by name, like the Treasurer. It opens on **the Throne Room** (the queue of
his court while it is open, and the army's key), and holding court takes him there. Since 1.1.5
the Treasury has its own tab alone, and under the Throne Room are **the Shogun's guild's Legates**:
up to 25 explicitly appointed members, named by the Shogun or real High Council. A council title
does not automatically appoint a group leader. Each Legate organizes an agreed group of up to
40 including themselves in the War Room. Each of his tools lives where it belongs:

*The list is in the README, with the rest of this section: [The Throne (the Shogun and his Hands)](https://github.com/dnl-gentile/bankai-addon#the-throne-the-shogun-and-his-hands).*

### The Shogun's Steward (1.0.0)
The Shogun's right hand, so that he needn't set everything up himself: a character the author
marks as **Steward** in the High Council's signed titles list. On the Steward's client the
Throne opens as the Shogun's, with **Acting for the Shogun** on top of every page, and in the
Shogun's name he:
- names and removes **Hands of his own**, beside the Shogun's (the Hands button on the Throne):
  the Shogun's list stays the Shogun's, and his own is his;
- names and removes the **treasury's keepers**, and sets **what the army sees** of the
  treasury (its three switches), on the Treasury tab, and **sees the whole treasury as the Shogun
  does**: the balance, the ranking, every keeper's shared book and the guild bank, whatever the
  switches (every keeper is told so before he shares his book);
- uses every tool of a Hand: the Agenda, Summon the Elders, the Royal Inspection, Poll and
  the gates;
- sends the **Crown's decrees** for `<Elfcore>` (Royal decrees, Tabard inspections, Calls to Arms,
  Musters), whatever his own rank: every client takes them by his name, `<Elfcore>`'s own
  members' too, and they never wait behind the flood guard, like the Shogun's. For the other
  guilds his [Elders] lines are the Crown's, as the Hands' are.

*Continued in the README: [The Shogun's Steward (1.0.0)](https://github.com/dnl-gentile/bankai-addon#the-shoguns-steward-100).*

### The Treasury (its keepers, the Shogun, and the army when the Shogun says so)
A tab with a coin for the treasury's keepers, for the Shogun, and for every member once the Shogun
shows the army something of it (1.1: for every member on the Treasurer's realms, with the dues' button
alone until then).

*Continued in the README: [The Treasury (its keepers, the Shogun, and the army when the Shogun says so)](https://github.com/dnl-gentile/bankai-addon#the-treasury-its-keepers-the-shogun-and-the-army-when-the-shogun-says-so).*

### Loot notes (1.1)
Loot arguments restart every raid because nobody kept last week's decision: the **Loot notes** of
your guild keep it (on the Realm tab, or `/bk loot`).

*Continued in the README: [Loot notes (1.1)](https://github.com/dnl-gentile/bankai-addon#loot-notes-11).*

### Crafters tab (1.1.4)
"Who can make this?" is a chat scroll: the top-level **Crafters** tab turns it into one
whisper to a named crafter (`/bk craft`).
- When you open one of your professions, Bankai Guild reads it (its skill, and the recipes you know:
  their recipe and item ids, never a specialization tree) and asks once, in a window of its own,
  whether to list it. With your yes the board of every Bankai Guild player of your realm and faction
  shows you: your name, guild, that profession and its skill. `/bk crafter off` takes you off at
  once; `/bk crafter on` lists every profession read again.
- **Ask who can make an item**: shift-click it after `/bk craft` (or type part of its name). The
  crafters listed who know its recipe answer by whisper, their addons by themselves; the page shows
  who can, with their skill and the item, and a click whispers one of them. (From 1.2 the tab's
  **Ask who can make an item...** button opens the request page instead: see below.)
- A crafter's row opens a whisper to him and, on a click, the recipes he listed (hover one for the
  item). Search the board by crafter, guild or profession.
- It stays light on the Bankai Guild channel and on your own messages: your listing goes once at login,
  every 45 minutes, and after a change (a profession listed or taken off 2 minutes after the last
  at the soonest, a skill up 10 minutes), so about 1.3 an hour while you play and 6 at most while
  you level. Your recipes go a part each 6 seconds (10 messages a minute at most), to two players
  at a time, and only while your addon's own messages (the census first) are few; the next player
  is told you are busy and clicks again a minute later.
- Nothing is crafted, ordered, bought or sold for anyone, nothing touches the auction house, and
  nothing is whispered for you: the whisper is yours to write. Old clients ignore the board.

### Crafting requests (1.2)
On the **Crafters** tab, **Ask who can make an item...** opens the request page: search an item
(your own recipes, the recipe lists other crafters sent you, the answers to your `/bk craft` ask,
and gathered herbs, ores and leathers) or paste its link, choose the quantity and the details, and
publish the request to the board.
- The request is a card on the board of every Bankai Guild player of your realm and faction: the item and
  quantity, your guild, who brings the materials, a price reference and your details. It only ever
  says open, taken, cancelled or expired: never who took it, the terms or how it ended.
- A listed crafter who makes it, or for a gathered material a player whose own Herbalism, Mining or
  Skinning skill shows it (read on his client, sent nowhere), sees it marked and hears it once. The
  first claim to reach the requester wins; everything after it (the terms, the delivery, the
  request's chat) is a logged whisper between the two of them, and on the guild-mediated rail with
  the treasury keeper who holds the goods and the gold. Bankai Guild fills a mail or says what to send:
  you press Trade or Send.
- Once a claim wins, Bankai Guild opens the request's own chat on both players' Chat tab, with the
  Bankai Guild window in front. It waits as Bankai Guild's other windows do: in an instance or Busy until you
  are out (its line waits on the Decrees tab), in a fight until it ends, and while you are typing
  in the Chat tab's box until you send or leave it; by then it opens only if the deal is still
  open. It stays while the deal is open; once the deal is over you may remove it, and the
  request's **Open chat** brings it back.
- **The guild's 6% of a direct sale**: the seller owes the guild 6% of each direct sale made through
  the board, in gold, by 3 days after the sale the buyer confirmed (a sale the buyer never confirmed
  and nobody disputed owes it all the same, 3 days after the delivery the seller recorded or the
  trade both addons saw). He mails it to the guild's fee receiver (the Treasurer's mail character)
  titled "Bankai Guild craft fee" and the request (his sale's line fills the mail). Late, he is warned and
  takes no new requests until it is paid; a fee mail that comes back is owed again. Both parties'
  addons tell the Treasurer's characters of the sale. The Treasurer, the Shogun, the High Council and
  the author see the debtors, the most overdue first, each with his step on the guild's ladder (late,
  a warning from his guild's Watch, his guild's decision up to removal), and every fee owed; the
  reminders to a debtor are the Treasurer's and the Shogun's. A sale only the buyer reported, or
  a buyer's price above the seller's, waits apart until the Treasurer confirms it. Nothing here
  removes anyone. There is no guarantee fund yet.

### The Missionary Church of Bankai Guild (1.1.6)

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

*Continued in the README: [The Missionary Church of Bankai Guild (1.1.6)](https://github.com/dnl-gentile/bankai-addon#the-missionary-church-of-bankai-guild-116).*

### World map
- Soldiers per zone on zone and continent maps, and per continent on the world map (none with
  Blizzard's gamepad mode since 1.1.5: see below).
- Decrees are round icons (the horn, the war cry...) where they were called, and the Shogun's
  crown where he stands; the Board's camps (1.1) one fire badge per zone, with how many. Over a
  zone's circle they move just outside its edge, top right first, so its number stays readable;
  several around one circle each take a place of their own.
- The round **Bankai Guild** button in the bottom left corner of the map switches markers
  (army per zone, decrees, camps) on and off.
- Every zone of the game counts, not only Azeroth's (1.1): on TBC Anniversary Outland's zones
  get their circles, and Outland's total shows on the map above Azeroth and Outland. A zone a
  new patch adds is found by itself the first time a guildmate stands in it; one the addon still
  can't place shows as plain text in the census, and `/bk status` (and `/bk bug`) lists its
  name under "zones without a map id".

### Bankai Guild Link: your Discord role (1.0.0, optional)
Prove to the Bankai Guild bot on Discord that a character is yours, and the bot gives you your role.
It is the one part of Bankai Guild that goes outside the game, and only if you choose to link a
character (or to confirm other players' links, below): no password, no Battle.net login, and
nothing is sent before you say yes.

Not open yet: the addon carries it, but `/bk discord` says it is not open until the Bankai Guild bot
is ready and its key is in the addon. Until then no addon makes, keeps, announces or uses a
confirmer key.

1. **Get a code** from the Bankai Guild bot on Discord (its `/verify` command, in the Bankai Guild server:
   only you see the reply). It is good for 24 hours. Keep it to yourself, and don't show it (or
   the Bankai Guild Link window) on a stream.
2. **Type `/bk discord <code>`** in the game's chat. The addon checks the bot's signature on the
   code, then asks whether to link this character to the Discord account the code names (the
   bot's word: nobody can change it). **Cancel** sends nothing.
3. **Players confirm in game**, by addon whisper, that this character asked: a High Councillor
   online, or, when none is, verified players drawn for your code (three of them must confirm).
   Each signs with a key of its own, for its character, which the bot certified. Every confirmer,
   High Councillors included, gets a key from the bot's keeper, made on a computer, and types it
   in the game with `/bk discord key <id> <key>`, then its certificate with
   `/bk discord cert <certificate>`; no addon makes a key of its own (the author's council
   authority, which could certify keys made in game, is off). Once the bot is ready, a
   confirmer's addon says so on the Bankai Guild channel every 5 minutes and signs other players'
   requests by itself (`/bk discord key off` stops it).
4. **The proof reaches the bot.** The **Bankai Guild Link** window shows a QR code and the same link
   in a copy box. Open the Bankai Guild Link page, https://dnl-gentile.github.io/bankai-addon/ (a
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
it. **Delete my link**, at the foot of the Bankai Guild Link page (signed in with Discord), takes the
role away and deletes what the bot keeps about your account, except how many codes and links you
used today, counted for a day at most. The Bankai Guild bot is Fernmelder's; how it checks a proof
is on [GitHub](https://github.com/dnl-gentile/bankai-addon) (the README and `web/FERN.md`).
`/bk discord show` opens the window again, `/bk discord status` lists every character of your
account, `/bk discord forget` drops this character's request and proof.

### Everywhere
- **Copy**: every tab produces a ready-to-paste text for Discord.
- **Version letters** (1.1.5): after the addon updates, once a version, a short letter on
  parchment, in a window like the Bankai Guild window's, says what changed in that version, in the
  dev's own words. It waits until the privacy page is closed, and never opens in combat, in a
  dungeon or outside an Bankai Guild guild. Without saved history the letter stays quiet and unread.
  If the beta forgets saved data, it cannot detect updates; manual history stays available
  without repeat login popups. With retained data, updates can show once. The Bankai Guild window's help button
  (the **i** left of the X) keeps every letter: **Version letters** on its page lists them,
  newest first, and a click opens one; `/bk letters` (or `/bk letters 1.1.4`) does too. Nothing
  is sent: which letters you saw is kept on your computer, for your account.
- **What this client saw** (1.1, the Decrees tab and `/bk log`): a log of the acts your addon
  took while you were online (decrees, the gates opening and closing, pardons, the Shogun's
  visibility switches for the treasury and the untabarded list, and the shared block terms'
  edits), each with the sender's name as the server stamped it, the newest 300. So "who opened the gates" has an answer after the message
  is gone. Only acts heard from whoever did them: a repeat or a relay of someone else's act (the
  Treasurer's book carrying the Shogun's switches, another editor's list carrying a block term) and
  a state caught up on after a later login are not written. On the Shogun's screen, while the
  council's names are hidden there (his stream), every sender but the Shogun shows cut short, and
  the shared terms' words too, as everywhere on his screen. Kept on your computer only, never
  sent, never in `/bk bug`; a record, not proof (anyone can edit their own saved files). The
  Decrees tab lists it with a search box and a copy; `/bk log [n | word | copy | clear]` in chat.
- **Backup** (1.1): `/bk backup` puts one text in the copy box (keepers also have **Copy a
  backup of your book and settings** on the Treasury tab): this character's book of the treasury
  (its opening, its 500 lines and its sums of all time, each giver's weeks of the dues and each
  week's amount with them; on the Treasurer's characters his mail
  character's book too), the Shogun's switches and keepers on his client or a Steward's, and your
  settings (sound, map, minimap, borders, nameplates, Poll, your chat windows and mutes, the
  players you blocked), and (1.2.4) your own signed halves of the Bones games and duels that count
  (this month's and last month's Bones games, the newest 400, and your newest 200 duels; never
  the other player's: a Bones game's comes back when your addon asks him, a duel's from his
  repeats or the clerk's carousel). Keep it in a text file: when the beta wipes the saved
  variables, `/bk restore` opens a box to paste it back, says what it restores and waits for
  your yes. Clipboard
  only: nothing is uploaded or sent anywhere (a keeper's book goes out afterwards as it always
  does). A book goes back only into that character's (merged with what it wrote since, nothing
  counted twice), a text that was cut or changed is refused, and it never holds your yeses to
  sharing (the addon asks them again). It never holds or sets the channel key, on anyone's
  character: a text someone else made would move your guild to another channel (your officers
  hand the key out in game as ever, or `/bk key`); the confirm says a key in a text is left out,
  and warns when it is one your guild replaced. The players it would block are named one by one
  in the confirm (30 at most) and added only on your yes.
- **Search**: a box on top of the Census (guilds, Elders, Council, players, zones, recruiting),
  the Realm (guilds, Elders, Council, members seen online), Crafters (crafter, guild or profession), the
  Tabards (inspected and untabarded players, by name or guild), the Treasury (donors in the
  ranking and the book, and since 1.1 the bank's items), the Decrees (since 1.1: the log of what this client saw) and the Chat tab (since 1.1.1: a name, a guild or words of a line). Any case, accents too; only what matches shows, under the headers it belongs to (a Council member under his guild, opened
  for you, a page of guilds at a time), with an **x** to empty it. Each tab keeps its text until
  you log out or `/reload`; a guild clicked in the Census opens in the Realm with its box emptied.
  It only changes what the list shows: **Copy** still gives everything, and nothing is sent.
- The window opens from `/bk`, the minimap button, or the round button in your guild window:
  the old Guild tab or the new Guild & Communities window, whichever one you use.
  Shift-click the minimap button for the Chat tab (1.1.1, above).
- Next to Forever's Guild & Communities window it takes that window's look: icon tabs down
  the right side, its rows, column headers, buttons and member card. When the tabs do not all fit
  down that side, the canonical tail continues from the bottom of the left edge upward. Reading
  the right top-to-bottom and then the left bottom-to-top always gives the same tab order.
- **Blizzard's gamepad mode** (Forever's controller interface): Bankai Guild asks its questions in
  windows of its own instead of the game's popups, which Blizzard's gamepad code blocks (and
  freezes) when an addon opens one. With mouse and keyboard, the game's popups as always.
  Since 0.9.8 it also leaves the game's own frames alone there: no quiet `/who` on its own
  (**Refresh** and **Find Bankai Guild online** still search, and so does the Shogun's click on his
  Throne's /who line for his key rotation, 1.1: the answer shows in the game's
  Who list), and the Issue Reporter is the game's to show. Since 0.9.9 it leaves the world map
  alone there too: no zone counts, decrees, crown or guildmate dots on it (the minimap keeps
  the crown and the dots), because each of those went through the map library into the gamepad
  map's own state; since 1.1.5 its continent totals and Bankai Guild button go too, the gamepad map
  being the game's alone. If the game still says it blocked
  Bankai Guild, a `/reload` clears it; to tell us what it was, open the Bankai Guild window, press its
  help button (left of the X), then **Report a bug**.
  **The gamepad gate (1.1.5).** Every way Bankai Guild reaches into the game's own windows is listed in
  one place and asks one gate before it acts, so a new feature can't reach them with the gamepad
  UI on by accident. With the gamepad UI on, Bankai Guild registers no typed command (`/bk`,
  `/bankai`, `/bg`, `/bgc`, `/bgl`): the game's chat box runs a command's function and then
  closes itself in that function's name, which is the very call the gamepad UI refuses. Nor does
  it put its round button in the game's guild windows, where the gamepad cursor would select it.
  Open Bankai Guild with the minimap button (it shows there even when `/bk minimap` hid it), and use
  its window (its help button: **Report a bug**). Switched to the gamepad UI in the middle of a
  session (Options, Gamepad), Bankai Guild steps back from the game's windows on the next frame: its
  marks, borders and buttons there hide, its tooltip lines and menu lines stop, and what the game
  keeps until a `/reload` (the commands typed with mouse and keyboard among it) is told once, in
  Bankai Guild's own window, with a **Reload** button. Back to mouse and keyboard, it all comes back
  without a `/reload`.
- English and Portuguese in full, and since 1.1 Spanish, French and German for the main
  screens, the alerts and decrees, the Join screen and its whisper, the chats and the privacy
  questions (the rest in English; the pages' **?** explanations and the Answers of 1.1.2 are in
  English too). It follows the game language, and only the text on your
  screen changes: nothing sent between players does. `/bk status` shows the language in use.

### Other addons: the Bankai Guild API (1.2.4)

Another addon can read, with your permission, what Bankai Guild already shows you: the Wanted list
and its bounties, the public rankings (the Slayers, the Church's top three, the games the Shogun
made public, the donors' top three while he shows the Treasury's ranking), your own frame and
title, your Bankai Guild guild, rank and role, and the Shogun's presence as his lines and the Realm tab
show it (online, the zone they name, his crown while he shares it, whether you are on his layer,
and his zone's layers with their "~N with Bankai Guild" counts while you are there). The Shogun's
presence, the player-sighting searches and the profile presentation below are reserved for addons
the Bankai Guild team has authorized; any other addon is asked only about the rest. An addon that asks gets its own line on the privacy
page and nothing until your **Yes** there or the page's deliberate **Authorize all** action
(`/bk privacy` changes it at any time; **Keep current choices** grants nothing). Ordinary reads
send nothing. A compatible addon can also let an authorized player start a short exact-name
last-seen search, maintain a bounded set of exact-name searches while a visible tool session the
player started remains on, or start a five-minute hostile-area search for one selected zone or
micro-map, which may be widened to labelled not-hostile players outside Bankai Guild guilds (or with
none), never the observer's group. Its visible Start declares selected/configured names and any included list source. A
handle has one area at a time: current map or an owned exact-result map until its row expires, then cancel
and wait 60 seconds to rotate. Its UI shows map/position and Stop/Off; it never opens the map or
resumes after No or `/reload` automatically. Bankai Guild sends each exact **Name-Realm** sought, or the
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
withdraws them. On an explicit action the requester can show sanitized area rows with BankaiGuild-owned
world-map pins; they clear on cancellation, expiry, permission revocation or `/reload`. Bankai Guild
can also host one bounded profile presentation. A current signed issuer or the addon's author opens it; an admitted
member may enable only Bankai Guild's fixed style and pre-approved caption on themself. It accepts no target, asset path or arbitrary text,
and **No** closes that addon's state. Bankai Guild
never gives another addon the census, other players' private data or Bankai Guild's keys; each addon gets
its own bounded copy. What that addon then does with a copy is up to it, so authorize only addons
you trust. After the update it loads once the game restarts (not on a `/reload`).

*Continued in the README: [Other addons: the Bankai Guild API (1.2.4)](https://github.com/dnl-gentile/bankai-addon#other-addons-the-bankai-guild-api-124).*

## Install

**Easiest:** install **Bankai Guild Guild** from the CurseForge app or WowUp. It installs in the
right place and keeps it updated. For Forever, pick the Forever (beta) installation of the
game in the app, not Classic Era.

**By hand:**
1. Download `BankaiGuild-x.y.z.zip` from the **Files** tab here (or [GitHub Releases](https://github.com/dnl-gentile/bankai-addon/releases)).
2. Open your World of Warcraft folder. On Windows it is usually
   `C:\Program Files (x86)\World of Warcraft\` (on Mac: `/Applications/World of Warcraft/`).
3. Open the folder of the game version you play. For the **Forever beta** it is the one with
   *beta* in its name (for example `_classic_beta_`); Classic Era is `_classic_era_`, TBC
   Anniversary is `_anniversary_`.
4. Go into `Interface\AddOns\` (create `Interface` and `AddOns` if they don't exist) and
   extract the zip there, so you end up with `...\Interface\AddOns\BankaiGuild\BankaiGuild.toc`.
   Careful: Windows' *Extract All* adds a folder named after the zip
   (`AddOns\BankaiGuild-0.8.1\BankaiGuild\...`). If that happens, move the `Bankai Guild` folder up into
   `AddOns`; the game only loads it from `AddOns\BankaiGuild\`.
   From 1.3.3 the zip holds three folders: `Bankai Guild`, `BankaiGuild_Arena` (the Blood Arena's screens,
   loaded only when you open the arena) and `BankaiGuildSiteAggregate` (the deliberate, no-upload
   website reporter). All three go in `AddOns`, and all three move up if *Extract All* added a
   folder. Keep them together and update them together; both additional folders need Bankai Guild enabled.
5. **Restart the game.** If the addon list says *out of date*, tick **Load out of date AddOns**.

The addon only shows **live data**: guilds appear as soon as one of their members with the
addon is online (give it a few minutes). There is no demo mode any more.

**One member per guild is enough** for that guild to appear for everyone. The more guilds
have at least one install, the more complete the census gets.

### For officers: seal the channel (recommended)
Type once, with a secret the Bankai Guild officers agree on:
```
/bk key <secret>
```
Your guildmates with the addon receive it automatically through guild chat. From then on
the Bankai Guild channel has a name and password derived from the secret, and outsiders can't
find or join it. Share the same secret with the officers of the other Bankai Guild guilds
(for example in the officers' Discord), so all guilds meet on the same sealed channel.
Since 1.1 the Shogun (or his Steward, for him) can also rotate the army's key from the Throne: his new key reaches the
Elders and Council online of the guilds he picks whom his own /who saw in them by whisper, and
their guilds over guild chat, never on the Bankai Guild channel.

If a guild was accidentally given a different private key and lost the shared census and
Bankai Guild chat, one of its current officers can use `/bk key off`. The recovery instruction stays
inside Blizzard's guild channel, returns updated guildmates to the public Bankai Guild channel, and
retires the old private key so a delayed message cannot split them again.

## How it works

1. Every guild member can read their own guild's roster: name, level, class, zone, rank,
   online and last seen.
2. Members with the addon find each other through hidden addon messages in guild chat and
   **elect one reporter per guild**. The first name alphabetically wins, and every client
   computes the same answer.
   Each realm of WoW: Forever has a hidden channel of its own, so a guild with members on
   several realms elects one reporter on each realm (since 1.0.0).
3. The reporter sends a compact summary of its guild about every 3 minutes on the hidden Bankai Guild channel.
4. Every client adds up all the summaries: that is the census.

The addon itself talks only in game, through the game's own addon messages: it has no server of
its own, and nothing it sends leaves the game. One exception is Bankai Guild Link (above), and
only when you choose to link a character: it uses a website (the Bankai Guild Link page, on the
project's GitHub Pages) and the Bankai Guild bot on Discord. A confirmer (a key from the bot's keeper)
signs other players' requests by itself once the bot is ready, and those signatures reach the bot
in their proofs. The other is the Bankai Guild Companion app, only if you install it (Privacy, below).

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
and what it sends stays in the game. One exception is Bankai Guild Link, and only when you choose
to link a character, or to confirm other players' links: a link's proof goes to the Bankai Guild bot
on Discord, through the Bankai Guild Link page on GitHub Pages (where you sign in with Discord) or a
High Councillor's watcher. A confirmer, a High Councillor too, is someone who typed in a key the
bot's keeper made them (no addon makes or announces a key by itself, and the author's council
authority is off): once the bot is ready, their addon says so on the Bankai Guild channel every 5
minutes and signs other players' requests by itself, and their character's name and signature
reach the bot in those players' proofs, until `/bk discord key off`. The other is the Bankai Guild
Companion app, only if you install it: its own bridge addon takes your character's name and
BattleTag and the Bankai Guild and guild chat lines your client shows to Bankai Guild's server, for its staff
alone (the Companion's rows below). Your name is on every message (the game adds it). What goes where:

*The table is in the README, with the rest of this section: [Privacy](https://github.com/dnl-gentile/bankai-addon#privacy).*

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
a roll call is answered only after the player's yes (the first-open page, or `/bk rollcall on`),
and `/bk rollcall off` refuses both. Since 1.1 your addon also reads the released version his addon
announces on the channel (his presence): newer than yours, the Census, `/bk status` and one chat
line a session tell you to update. That is local to your client, sends nothing, and shows
whatever `/bk rollcall` says. He runs a new build on his own PC before it is published, so his
presence names only the version he marked as out with `/bk released [version]` (his character
only; the Workshop tab shows it) once CurseForge lists it, never the build he runs, and never one
newer than that build; addons before 1.1 read none of it. The addon's error catcher keeps only Bankai Guild's own errors (for
`/bk bug`), never another addon's. For the store's screenshots he has a photo mode (`/bk
photo`, his character only): on his own screen it fades everything but Bankai Guild and the world
map to invisible, and gives every frame its look back on the second `/bk photo` or a
`/reload`. Never in combat, not with the gamepad UI, not on a screen of more than 1000 frames
(it says so and leaves them as they are), and nothing is sent to anyone.
To check the elite borders his own rank doesn't carry, `/bk borders test <tier>` (his
character only) shows one of the borders round his own portrait, and on his target frame when he
targets himself, and its nameplate mark after his own name on his player frame and on every
friendly player's nameplate (`/bk borders test member`: the member's star alone), on his screen
alone until `/bk borders test off` or a `/reload`. It follows the borders' and the marks' own
rules (none with the gamepad UI, made out of combat), and nothing is sent.

The addon is plain Lua running on each player's computer, so anyone can edit their own
copy. No addon can prevent that. What this one does is check what every copy sends; what a
few characters working together can still reach is said plainly further down
([What colluding characters can reach](#what-colluding-characters-can-reach)):

*The list is in the README, with the rest of this section: [Security and trust](https://github.com/dnl-gentile/bankai-addon#security-and-trust).*

### What colluding characters can reach

Votes are counted per sender name, and nothing the server tells an addon proves which guild a
sender belongs to: a census report is its sender's word. So a few characters working together
can still reach the following today (1.0.0); each outcome was checked against this version's
code.

*The list is in the README, with the rest of this section: [What colluding characters can reach](https://github.com/dnl-gentile/bankai-addon#what-colluding-characters-can-reach).*

## Built for a crowd of thousands

- One summary per guild about every 3 minutes, not one per player.
- In a full guild only the members who could be elected keep saying hello; the rest go quiet.
- Layers are announced by officers plus a stable 1 in 8 sample who share them, every 10 minutes
  (the Shogun's alone every minute, while his crown shows: one client, one message a minute).
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
| `/bk` | open or close the window |
| `/bk realm` · `/bk decrees` · `/bk tabard` | open a tab |
| `/bk loot` | your guild's loot notes and points on the Realm tab (its officers write them; not a bid window) |
| `/bk craft [item or name]` · `/bk crafter on\|off` | who can make it (the top-level Crafters tab: shift-click an item after `/bk craft`); list your professions read so far, or take them off |
| `/bg <text>` · `/bgc <text>` | write in [Bankai Guild] or [Council]; alone (`/bg`, `/bgc`): open the Chat tab on that channel (1.1.1) |
| `/bk mute bankaiguild` · `/bk mute council` | hide or show a channel in chat |
| `/bk chatwindow tab` · `/bk chatwindow <number or name> [bankaiguild\|council\|elders]` · `/bk chatwindow main` | the Bankai Guild chats in a chat tab named Bankai Guild (without the channel's name; it says how to make the tab), in another chat window (with Chattynator, one of its tabs, by name), or back in the main one |
| `/bk privacy` | the first-open page again: what the addon shares, and your Yes or No to each (1.1) |
| `/bk chat on\|off` | the Bankai Guild chats on this client; off, nothing is sent or shown (1.1: off until you say yes) |
| `/bk talk [bankaiguild\|council]` | open or close the Bankai Guild window on its Chat tab, on that channel; also `/bg` or `/bgc` with nothing after it, or Shift-click the minimap button (1.1.1) |
| `/bk helpme [text]` (or **Ask a High Councillor** on the Realm tab) | ask the High Council (the moderators) for help: it goes by whisper to up to three of them online who take requests |
| `/bk discord <code>` · `/bk discord` | Bankai Guild Link: link this character to your Discord account with the bot's code (or paste it in a box) |
| `/bk hop` | ask for an invite to the Shogun's layer (while he is online) |
| `/bk lfg` · `/bk lfg dungeon\|raid\|pvp\|layer [note]` · `/bk lfg off` | the Board (1.1): who is looking for a group; raise your flag (a box with your note first) or lower it |
| `/bk week` | the week on the Board and Decrees: army and own-guild Agenda entries for 7 days, alongside your guild's calendar; eligible schedulers see separate army and guild buttons ("Sat 20:00 Raid night") |
| `/bk location on` · `/bk location off` | share (or not) your zone and layer on the Bankai Guild channel |
| `/bk borders on` · `/bk borders off` | elite borders round the portrait of your target, focus, party members and your own frame (Forever): the game's gold wings for the Shogun, silver wings for the High Council and Max's bronze wings for Bankai Guild guild masters (none for a character or guild the moderators took off, net-off). Legates and correspondents use separate verified office shields instead of the old wingless bronze role frame; signed High Council departments use the same shield family without replacing silver, and earned honours remain. Since 1.1.5 the old rank borders (gold for Elders, silver for Council, bronze for Raiders and Veterans) are gone, and any other member has the nameplate star alone. On by default, hidden with the gamepad UI. Off, the nameplate marks go too |
| `/bk nameplates on` · `/bk nameplates off` | a small mark left of the name on friendly players' nameplates (Forever; friendly nameplates show with Shift+V): the game's gold elite mark for the Shogun, silver for the High Council, bronze for guild masters, the verified Legate or department shield for an appointee, and a star for any other member of an Bankai Guild guild (none for a character or a guild the moderators took off, net-off); on by default, hidden with the gamepad UI and with `/bk borders off` |
| `/bk chatmarks on` · `/bk chatmarks off` | 1.1.5: the verified mark before a player's name in the game's own chat (channels, say, yell, emote, party, raid, instance and whispers; guild and officer chat the office marks alone, never the star): the Shogun's gold dragon, a High Councillor's silver then their icon, a guild master's bronze, the Legate or department shield for an appointee, and the star for any other member your addon can check. Bankai Guild's own lines carry none. Through the game's own name filter, so the name's link, right-click and /r stay the game's; on by default, hidden with the gamepad UI, and a councillor's on the Shogun's screen while the council's names are hidden |
| `/bk block <name>` | ignore a player |
| `/bk filter add\|remove <word>` · `/bk filter` | block terms: hide, on your screen, lines of addon text (Bankai Guild chats, writs, decrees, Poll) with a word; the list (1.1) |
| `/bk alt add Name` · `/bk alt remove Name` · `/bk alt` | link a character of this account as your alt (log it and say yes there), take a link apart, or see your links: the census and the treasury count you once (1.1) |
| `/bk sound` · `/bk sound on\|off` | every alert sound on or off |
| `/bk bug` | copyable bug report (also: the help button left of the window's X, then **Report a bug**) |
| `/bk status` | diagnostics in chat (1.0.0: whom your addon knows as the Shogun's Steward, and the lists of Hands it holds, whose each is; 1.1.2: the author's in a copy window) |

*Every command in the README: [Commands](https://github.com/dnl-gentile/bankai-addon#commands).*

## Reporting a bug

While the addon's author is online, the **Report a bug** window also has a **Send to
Faladoriel Skylance** button: your report goes to him in game, by addon whisper, and nowhere
else (once every 10 minutes at most, unless he asked for it). It first checks he is really there: the rest follows
only once he answers, and you are told when he got it.

Since 1.1.2 the author can also ask you for it from the right-click menu: your addon shows you
the exact text first, in a window of its own, and sends nothing without your **Send**.

Type `/bk bug` (or press **Report a bug**), copy the text and open an issue on [GitHub](https://github.com/dnl-gentile/bankai-addon/issues). Errors are
also saved in `WTF/Account/<ACCOUNT>/SavedVariables/BankaiGuild.lua`.

## Credits

- **Shobek** and his team (Daily Dose of Shobek, Max, Heuto, Fernmelder and the High
  Council), for making Bankai Guild the army's addon and for the ideas.
- **Security reviews:** Konig, bjess9 (jess), elderjumper and Fadirstave, who read the code and
  showed what an attacker could do.
- **Code and ideas:** RoyLeviGit (Bankai Guild chats in their own chat window), Artz (hiding the
  Issue Reporter), bjess9 (CI and the shared checks), hypertectonic (Chattynator's tabs),
  Bernardo Costa / Costafitness (exact layer-hop confirmation and stale-request regressions,
  adapted from PR #51), and Rick-laboratory (bounded transport, cancellation and admission
  regressions, adapted from PR #52).
- **Feature requests:** Fernmelder, whose 39 posts became 1.1 (the Fernmelder release);
  shenanigans_ (the nameplate marks), Valdericht (`<ELF>`), Pyralis Ashandar (taking
  donations) and Zeal (what the Shogun hides stays off the channel).
- **Art:** Max (the bronze elite borders, drawn over the game's own; the winged one remains the guild masters').
- **Reports from the field:** Riukensei and PartyRockAce (the gamepad UI; PartyRockAce's report
  of the world map blocked in controller mode, fixed in 1.0), Ignitheus (whispers to Forever
  names), Pyralis Ashandar, the Treasurer (the treasury and the guild bank), and the player who
  told us WoW had handed him the channel.
- Everyone who reported a bug, tested in game or asked for a feature.

## License

MIT. Not made or endorsed by Blizzard Entertainment. The Bankai Guild emblem belongs to its owners
and is used for the community.

*Sources for the Bankai Guild description: the Bankai Guild Discord welcome message,
[Prism on X](https://x.com/fwprism/status/2101809316382847172) (10K+ members in the beta),
[Dexerto](https://www.dexerto.com/world-of-warcraft/shobek-responds-as-wow-forever-players-want-him-banned-over-massive-bankaiguild-guild-3411199/).*


Source code: https://github.com/dnl-gentile/bankai-addon
