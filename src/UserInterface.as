void RenderMenu() {
    // Icons::Android +
    // Icons::FDroid +
    if (UI::MenuItem("\\$5af" + Icons::Kenney::Save + "\\$z Autosave Replays for MediaTracker", "", Setting_AutoSaveReplays, true)) {
        Setting_AutoSaveReplays = !Setting_AutoSaveReplays;
    }
}
