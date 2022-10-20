# Autosave Replays for MediaTracker

**These replays cannot be used via *Play > Local > Against Replay*. They are *only* suitable for cases like *Create > Replay Editor*.**

This plugin autosaves replays at suitable times, e.g., the end of a Time Attack session, or after each round in a KO match.
Thus, it's possible to save a viewable replay of each round of a COTD KO match if you want, for example.

If you want decent quality replays of all players, have opponents on or be in spectator mode. Otherwise YMMV.

The replays that are produced (saved in `Trackmania\Replays\AutosavedReplays`) can be used in the replay editor, and are probably able to be used as GPSs, etc. (IDK for sure, tho)
They are the same replays that are produced via the 'Save Replay' button (but the prompt doesn't show).

You will experience a stutter when autosave is turned on.
Expect a typically small stutter (50 - 250 ms) for few players and/or short sessions, and a bigger stutter (1000 - 2000 ms) for more players and particularly for longer sessions.
For COTD qualifiers the stutter can be 1 to 2 seconds.
Early COTD KO rounds have a stutter ~100ms.

Demo video loading saved replays in replay editor: [https://youtu.be/eSFR6YYNW3Q](https://youtu.be/eSFR6YYNW3Q)

Replays are saved when the `UISequence` is `Podium` or `UIInteraction`.
In KO rounds, `UIInteraction` happens at the end of each round, and the 'save replay' will save just that last race.
In Time Attack sessions, `Podium` happens at the end, and `UIInteraction` usually doesn't happens.
(The plugin won't save an extra replay when one follows the other.)

Note: there will be a noticeable lag spike at the end of long sessions with many players.
Many megabytes of replay data may be saved per session.

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-autosave-replays-for-mediatracker](https://github.com/XertroV/tm-autosave-replays-for-mediatracker)

GL HF
