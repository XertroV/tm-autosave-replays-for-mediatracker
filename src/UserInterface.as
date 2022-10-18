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
    if (dir.HasNoFiles(true)) return;
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
    auto id = "##" + file.path;
    UI::AlignTextToFramePadding();
    auto icon = file.isReplay ? "\\$f88" + Icons::VideoCamera : "\\$bbb" + Icons::SnapchatGhost;
    UI::Text(icon + "\\$z " + file.fileName);
    UI::SameLine();
    if (file.isReplay) {
        if (!file.hasLoadedGhosts) {
            if (UI::Button("Load Ghosts" + id)) {
                file.LoadGhostsAsync();
            }
        } else if (!file.loadComplete) {
            UI::Text("loading...");
        } else {
            UI::Text("" + file.ghosts.Length + " Ghosts");
            UI::SameLine();
            if (UI::Button("Load Ghosts")) {
                startnew(LoadGhosts, RepackOpts(file.shortPath));
            }
            UI::SameLine();
            if (UI::Button("Repack")) {
                print("repacking: " + file.shortPath);
                startnew(RepackReplayForPlayersGhostsCoro, RepackOpts(file.shortPath));
            }
        }
    } else if (file.isGhost) {
        UI::Text("");
    }
}

void LoadGhosts(ref@ _opts) {
    auto map = GetApp().RootMap;
    auto ps = cast<CSmArenaRulesMode>(GetApp().PlaygroundScript);
    if (ps is null) return;
    auto opts = cast<RepackOpts>(_opts);
    if (opts is null) {
        warn("RepackReplayForPlayersGhostsCoro got null opts");
        return;
    }
    auto rf = ReplayFile(opts.fileName);
    if (!rf.exists) {
        warn("RepackReplayForPlayersGhostsCoro replay (" + opts.fileName + ") does not exist");
        return;
    }
    rf.LoadGhostsSync();
    CGameGhostScript@[] playerGhosts = {};
    string playerName = GetPlayerName(GetApp());
    for (uint i = 0; i < rf.ghosts.Length; i++) {
        auto ghost = rf.ghosts[i];
        if (ghost.Nickname != playerName) continue;
        playerGhosts.InsertLast(ghost);
        ps.Ghost_Add(ghost, true);
        print("added ghost: " + ghost.Result.Time);
    }
}
