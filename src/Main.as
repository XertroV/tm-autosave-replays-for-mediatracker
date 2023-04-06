bool permissionsOkay = false;

void Main() {
    CheckRequiredPermissions();
    startnew(CreateReplaysDir);
    startnew(AutoSaveReplaysCoro);
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
#endif
}

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
void AutoSaveReplaysCoro() {
    CheckRequiredPermissions();
    while (true) {
        yield();
        if (!Setting_AutoSaveReplays) {
            sleep(1000);
            continue;
        }
        if (GetApp().PlaygroundScript !is null) { // don't check if we're in solo -- round detection broken + doesnt save anything useful anyway
            sleep(100);
            continue;
        }
        if (lastAutosave + 5000 > Time::Now) continue; // don't autosave within 5s of autosaving
        CGamePlaygroundUIConfig::EUISequence currUiSeq = CGamePlaygroundUIConfig::EUISequence::None;
        auto pcs = GetPlaygroundClientScriptAPISync(GetApp());
        if (pcs !is null)
            currUiSeq = pcs.UI.UISequence;
        bool sequenceOkay = SaveOnSequence(currUiSeq) && !SaveOnSequence(lastUiStatus);
        if (sequenceOkay && currUiSeq != lastUiStatus && pcs !is null) {
            auto replayFileName = "AutosavedReplays/" + FormattedTimeNow
                + "-" + StripFormatCodes(GetApp().RootMap.MapName)
                + "--" + pcs.LocalUser.Name + ".Replay.gbx";
            Notify("Saving replay: " + replayFileName);
            yield(); // give time for notify to show
            /* SavePrevReplay is not useful in time attack -- it will save nothing.
               It might save the prior round in KO matches. not sure
               // pcs.SavePrevReplay(replayFileName + "-prev" + ".Replay.gbx");
            */
            // in Time Attack it saves all ghosts up to now that the player has observed -- don't want to save early b/c it's just duplicate data
            auto saveStart = Time::Now;
            pcs.SaveReplay(replayFileName);
            lastAutosave = Time::Now;
            trace("Save duration: " + (lastAutosave - saveStart) + " ms.");
        }
        if (currUiSeq != lastUiStatus) {
            trace("updating ui seq. last: " + tostring(lastUiStatus) + ", new: " + tostring(currUiSeq));
            lastUiStatus = currUiSeq;
        }
    }
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
