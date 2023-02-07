bool DidRestartLastFrame = false;

#if DEPENDENCY_MLHOOK && DEPENDENCY_MLFEEDRACEDATA
void RespawnDetectionLoop() {
    uint lastStartTime = 0;
    while (true) {
        yield();
        DidRestartLastFrame = false;
        // skip non-local games
        if (GetApp().PlaygroundScript is null) continue;
        auto rd = MLFeed::GetRaceData_V4();
        auto player = rd.GetPlayer_V4(MLFeed::LocalPlayersName);
        if (player is null) continue;
        if (lastStartTime == 0) lastStartTime = player.StartTime;
        // when restart, start time goes up, nb respawns goes down
        if (player.StartTime != lastStartTime && currUiSeq == CGamePlaygroundUIConfig::EUISequence::Playing) {
            lastStartTime = player.StartTime;
            Notify('restarted');
            DidRestartLastFrame = true;
        }
    }
}
#else
void RespawnDetectionLoop() {}
#endif
