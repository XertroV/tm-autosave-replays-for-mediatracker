bool permissionsOkay = false;

#if DEPENDENCY_MLHOOK && DEPENDENCY_MLFEEDRACEDATA
const bool UserHasMLFeed = true;
#else
const bool UserHasMLFeed = false;
#endif

void Main() {
    if (UserHasMLFeed) Notify("MLFeed detected");
    CheckRequiredPermissions();
    startnew(CreateReplaysDir);
    startnew(AutoSaveReplaysCoro);
    if (UserHasMLFeed) startnew(RespawnDetectionLoop);
#if DEV
    testui(CGamePlaygroundUIConfig::EUISequence::None);
    testui(CGamePlaygroundUIConfig::EUISequence::Playing);
    testui(CGamePlaygroundUIConfig::EUISequence::Intro);
    testui(CGamePlaygroundUIConfig::EUISequence::Outro);
    testui(CGamePlaygroundUIConfig::EUISequence::Podium);
    testui(CGamePlaygroundUIConfig::EUISequence::CustomMTClip);
    testui(CGamePlaygroundUIConfig::EUISequence::EndRound);
    testui(CGamePlaygroundUIConfig::EUISequence::PlayersPresentation);
    testui(CGamePlaygroundUIConfig::EUISequence::UIInteraction);
    testui(CGamePlaygroundUIConfig::EUISequence::RollingBackgroundIntro);
    testui(CGamePlaygroundUIConfig::EUISequence::CustomMTClip_WithUIInteraction);
    testui(CGamePlaygroundUIConfig::EUISequence::Finish);
    Notify("loaded");
#endif
    sleep(100);
    // MLHook::RegisterPlaygroundMLExecutionPointCallback(ML_Update);
}

// void ML_Update(ref@ nullRef) {
//     // trace('exec');
//     try {
//         trace('is rules mode null: ' + tostring(cast<CSmArenaClient>(GetApp().CurrentPlayground).Arena.Rules.RulesMode is null));
//     } catch {
//         trace(getExceptionInfo());
//     }
// }

void testui(CGamePlaygroundUIConfig::EUISequence s) {
    print('' + uint(s) + ': ' + tostring(s));
}

const string SaveReplaysDir = IO::FromUserGameFolder("Replays/AutosavedReplays");
void CreateReplaysDir() {
    if (!IO::FolderExists(SaveReplaysDir)) {
        IO::CreateFolder(SaveReplaysDir);
    }
}

// check for permissions and
void CheckRequiredPermissions() {
    permissionsOkay = Permissions::CreateLocalReplay()
        && Permissions::PlayAgainstReplay()
        && Permissions::OpenReplayEditor();
    if (!permissionsOkay) {
        NotifyWarn("You appear not to have club access.\n\nThis plugin won't work, sorry :(.");
        while(true) { sleep(10000); } // do nothing forever
    }
}

CGamePlaygroundUIConfig::EUISequence lastUiStatus = CGamePlaygroundUIConfig::EUISequence::None;

bool SaveOnSequence(CGamePlaygroundUIConfig::EUISequence s) {
        return s == CGamePlaygroundUIConfig::EUISequence::UIInteraction
            || s == CGamePlaygroundUIConfig::EUISequence::Podium
            || s == CGamePlaygroundUIConfig::EUISequence::EndRound;
}

uint lastAutosave = 0;
CGamePlaygroundUIConfig::EUISequence currUiSeq = CGamePlaygroundUIConfig::EUISequence::None;
void AutoSaveReplaysCoro() {
    CheckRequiredPermissions();
    while (true) {
        yield();
        if (!Setting_AutoSaveReplays) {
            sleep(1000);
            continue;
        }
        if (lastAutosave + 5000 > Time::Now) continue; // don't autosave within 5s of autosaving
        currUiSeq = CGamePlaygroundUIConfig::EUISequence::None;
        auto pcs = GetPlaygroundClientScriptAPISync(GetApp());
        if (pcs !is null)
            currUiSeq = pcs.UI.UISequence;
        bool sequenceOkay = SaveOnSequence(currUiSeq) && !SaveOnSequence(lastUiStatus) && currUiSeq != lastUiStatus;
        bool saveDueToRestart = S_AutoSaveOnRestart && DidRestartLastFrame;
        if ((sequenceOkay || saveDueToRestart) && pcs !is null) {
            auto replayFileName = "AutosavedReplays/" + FormattedTimeNow
                + "-" + StripFormatCodes(GetApp().RootMap.MapName)
                + "--" + pcs.LocalUser.Name + ".Replay.gbx";
            Notify("Saving replay: " + replayFileName);
            yield(); // give time for notify to show
            /* SavePrevReplay is not useful in time attack -- it will save nothing.
               It might save the prior round in KO matches. not sure
               // pcs.SavePrevReplay(replayFileName + "-prev" + ".Replay.gbx");
               AutosavedReplays/2023-02-05 14-03-a1-Winter 2023 - 24--XertroV.Replay.gbx
               AutosavedReplays/2023-02-05 14-03-a2-Winter 2023 - 24--XertroV.Replay.gbx
               AutosavedReplays/2023-02-05 14-03-a3-Winter 2023 - 24--XertroV.Replay.gbx
               AutosavedReplays/2023-02-05 14-03-a4-Winter 2023 - 24--XertroV.Replay.gbx
               AutosavedReplays/2023-02-05 14-03-a5-Winter 2023 - 24--XertroV.Replay.gbx

            */
            // in Time Attack it saves all ghosts up to now that the player has observed -- don't want to save early b/c it's just duplicate data
            auto saveStart = Time::Now;
            pcs.SaveReplay(replayFileName);
            if (saveDueToRestart)
                pcs.SavePrevReplay(replayFileName.Replace('.Replay.gbx', '-prev.Replay.gbx'));
                // startnew(AutoSaveViaPrompt, array<string> = {replayFileName.Replace('.Replay.gbx', '-prev.Replay.gbx')});
            lastAutosave = Time::Now;
            trace("Save duration: " + (lastAutosave - saveStart) + " ms.");
        }
        if (currUiSeq != lastUiStatus) {
            trace("updating ui seq. last: " + tostring(lastUiStatus) + ", new: " + tostring(currUiSeq));
            lastUiStatus = currUiSeq;
        }
    }
}


void AutoSaveViaPrompt(ref@ r) {
    auto fileName = cast<string[]>(r)[0];
    auto pgsapi = GetPlaygroundClientScriptAPISync(GetApp());

}

const string get_FormattedTimeNow() {
    return cast<CGameManiaPlanet>(GetApp()).ManiaPlanetScriptAPI.CurrentLocalDateText.Replace("/", "-").Replace(":", "-");
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg, vec4(.1, .5, .2, .3), 10000);
    trace(msg);
}

void NotifyWarn(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg, vec4(1, .5, .1, .5), 10000);
    warn(msg);
}
