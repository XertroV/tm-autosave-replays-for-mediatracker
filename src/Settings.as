[Setting name="Auto-Save Replays at End-of-Round" description="When the round has the status of UIInteraction or Podium (end of round in KO, end of session in Time Attack), SaveReplay() will be called. Expect a typically small stutter for few players and/or short sessions, and a bigger stutter for more players and particularly longer sessions. For COTD qualifiers the stutter can be 1 to 2 seconds. COTD KO rounds have a stutter ~100ms."]
bool Setting_AutoSaveReplays = true;

#if DEPENDENCY_MLHOOK && DEPENDENCY_MLFEEDRACEDATA
[Setting name="Auto-Save partial Replays when you Restart" description=" in Solo"]
bool S_AutoSaveOnRestart = true;
#else
bool S_AutoSaveOnRestart = false;
#endif
