# Autosave Replays for MediaTracker

**These replays cannot be used via *Play > Local > Against Replay*. They are *only* suitable for cases like *Create > Replay Editor*.**

This plugin autosaves replays at suitable times, e.g., the end of a Time Attack session, or after each round in a KO match.

The replays that are produced (saved in `Trackmania\Replays\AutosavedReplays`) can be used in the replay editor, and are probably able to be used as GPSs, etc. (IDK for sure, tho)

Replays are saved when the `UISequence` is `Podium` or `UIInteraction`.
In KO rounds, `UIInteraction` happens at the end of each round, and the 'save replay' will save just that last race.
In Time Attack sessions, `Podium` happens at the end, and `UIInteraction` never happens.

Note: there will be a noticeable lag spike at the end of long sessions with many players.
Many megabytes of replay data will be saved.

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-extract-ghosts](https://github.com/XertroV/tm-extract-ghosts)

GL HF
