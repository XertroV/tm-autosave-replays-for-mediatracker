void RenderMenu() {
    if (UI::MenuItem("Autosave Replays for MediaTracker", "", Setting_AutoSaveReplays, true)) {
        Setting_AutoSaveReplays = !Setting_AutoSaveReplays;
    }
}
