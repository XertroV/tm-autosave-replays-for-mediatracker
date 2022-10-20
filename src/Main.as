bool permissionsOkay = false;

void Main() {
    CheckRequiredPermissions();
    startnew(CreateReplaysDir);
    startnew(AutoSaveReplaysCoro);
#if DEV
    Notify("test notify");
#endif
}

const string SaveReplaysDir = IO::FromUserGameFolder("Replays/AutosavedReplays");
void CreateReplaysDir() {
    if (!IO::FolderExists(SaveReplaysDir)) {
        IO::CreateFolder(SaveReplaysDir);
    }
}

// check for permissions and
void CheckRequiredPermissions() {
    permissionsOkay = Permissions::ViewRecords() && Permissions::PlayRecords()
        && Permissions::CreateLocalReplay() && Permissions::PlayAgainstReplay()
        && Permissions::OpenReplayEditor();
    if (!permissionsOkay) {
        NotifyWarn("You appear not to have club access.\n\nThis plugin won't work, sorry :(.");
        while(true) { sleep(10000); } // do nothing forever
    }
}

CGamePlaygroundUIConfig::EUISequence lastUiStatus = CGamePlaygroundUIConfig::EUISequence::None;

uint lastAutosave = 0;
void AutoSaveReplaysCoro() {
    if (lastAutosave + 5000 > Time::Now) return; // don't autosave within 5s of autosaving
    lastAutosave = Time::Now;
    while (true) {
        yield();
        if (!Setting_AutoSaveReplays) {
            sleep(1000);
            continue;
        }
        CGamePlaygroundUIConfig::EUISequence currUiSeq = CGamePlaygroundUIConfig::EUISequence::None;
        auto pcs = GetPlaygroundClientScriptAPISync(GetApp());
        if (pcs !is null)
            currUiSeq = pcs.UI.UISequence;
        bool sequenceOkay = (currUiSeq == CGamePlaygroundUIConfig::EUISequence::UIInteraction || currUiSeq == CGamePlaygroundUIConfig::EUISequence::Podium)
                         && (lastUiStatus != CGamePlaygroundUIConfig::EUISequence::UIInteraction && lastUiStatus != CGamePlaygroundUIConfig::EUISequence::Podium);
        if (sequenceOkay && currUiSeq != lastUiStatus && pcs !is null) {
            auto replayFileName = "AutosavedReplays/" + Time::Stamp
                + "-" + StripFormatCodes(GetApp().RootMap.MapName)
                + " " + pcs.LocalUser.Name + ".Replay.gbx";
            Notify("Saving replay: " + replayFileName);
            yield(); // give time for notify to show
            /* SavePrevReplay is not useful in time attack -- it will save nothing.
               It might save the prior round in KO matches. not sure
               // pcs.SavePrevReplay(replayFileName + "-prev" + ".Replay.gbx");
            */
            // in Time Attack it saves all ghosts up to now that the player has observed -- don't want to save early b/c it's just duplicate data
            pcs.SaveReplay(replayFileName);
        }
        if (currUiSeq != lastUiStatus) {
            warn("updating ui seq. last: " + tostring(lastUiStatus) + ", new: " + tostring(currUiSeq));
            lastUiStatus = currUiSeq;
        }
    }
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg, vec4(.1, .5, .2, .3), 10000);
}

void NotifyWarn(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg, vec4(1, .5, .1, .5), 10000);
}
