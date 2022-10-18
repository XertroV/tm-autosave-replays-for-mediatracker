/** Render function called every frame intended for `UI`.
*/
void RenderInterface() {
    if (!permissionsOkay) return;
    if (replaysRoot is null) return;
    if (!g_windowVisible) return;
    DrawMainWindow();
}

/** Render function called every frame intended only for menu items in `UI`.
*/
void RenderMenu() {
    if (UI::MenuItem("Ghost Extract 'n' Pack", "", g_windowVisible, true)) {
        g_windowVisible = !g_windowVisible;
    }
}

void DrawMainWindow() {
    if (UI::Begin("Ghost Extract 'n' Pack", g_windowVisible)) {
        DrawReplayDirTree(replaysRoot.root);
        // DrawReplayTree("rtroot");
        /*
          - list replays
          - list ghosts
          - ghost(s) -> replay
            - ghosts to dir
              - rip ghosts from replays first -- so start with .ghost.gbx files
            - make one replay (or: make all replays and then open them all at the same time)
              - CGameDataFileManagerScript CWebServicesTaskResult@ Replay_Save(wstring Path, CGameCtnChallenge@ Map, CGameGhostScript@ Ghost)
            - replay editor
              - EditReplay(MwFastBuffer<wstring>& ReplayList)
            - import all ghosts in directory
          - replay -> ghosts
            - easy, just load and save
        */
        UI::End();
    }
}

void DrawReplayDirTree(ReplayDirectory@ dir) {
    UI::AlignTextToFramePadding();
    // UI::Checkbox("##selected-" + id, true);
    // UI::SameLine();
    // bool treeOpen = UI::TreeNode(dir.folderName + "##" + dir.path);
    bool treeOpen = UI::TreeNode(dir.displayName + "##" + dir.path);
    if (treeOpen) {
        for (uint i = 0; i < dir.subdirs.Length; i++) {
            auto subdir = dir.subdirs[i];
            DrawReplayDirTree(subdir);
        }
        for (uint i = 0; i < dir.files.Length; i++) {
            auto file = dir.files[i];
            DrawReplayFileInTree(file);
        }
        UI::TreePop();
    }
}

void DrawReplayFileInTree(ReplayFile@ file) {
    UI::AlignTextToFramePadding();
    UI::Text(file.fileName);
}

void DrawReplayTree(const string &in id) {
    UI::AlignTextToFramePadding();
    UI::Checkbox("##selected-" + id, true);
    UI::SameLine();
    bool treeOpen = UI::TreeNode("test##" + id);
    if (treeOpen) {
        DrawReplayTree(id + "1");
        DrawReplayTree(id + "2");
        UI::TreePop();
    }
}
