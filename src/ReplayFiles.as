const string TmGameFolder = IO::FromUserGameFolder("").Replace("\\", "/");

class ReplaysRoot {
    ReplayDirectory@ root;
    ReplaysRoot() {
        lastYield = Time::Now;
        @root = ReplayDirectory(IO::FromUserGameFolder("Replays").Replace("\\", "/"));
    }
}

uint lastYield = Time::Now;
void RateLimit() {
    if (lastYield + 3 > Time::Now) {
        yield();
        lastYield = Time::Now;
    }
}


class ReplayDirectory {
    ReplayDirectory@[] subdirs;
    ReplayFile@[] files;
    string path;
    string folderName;
    private bool _exists;
    private string[] contents;
    bool hasLocalFiles;
    bool hasFiles;

    ReplayDirectory(const string &in dirPath) {
        path = dirPath.Replace("\\", "/");
        if (!path.EndsWith("/")) path += "/";
        _exists = IO::FolderExists(path);
        if (!_exists) return;
        contents = IO::IndexFolder(path, false);
        yield();
        auto parts = path.Split("/");
        folderName = parts[parts.Length - 2];
        for (uint i = 0; i < contents.Length; i++) {
            auto childPath = contents[i];
            if (IO::FileExists(childPath) && IsReplayOrGhostFile(childPath)) {
                files.InsertLast(ReplayFile(childPath));
                hasLocalFiles = true;
                hasFiles = true;
            } else if (IO::FolderExists(childPath)) {
                auto tmp = ReplayDirectory(childPath);
                if (!tmp.exists) continue;
                subdirs.InsertLast(tmp);
                hasFiles = hasFiles || tmp.hasFiles;
            }
        }
    }

    bool HasNoFiles(bool recursive) {
        return !(recursive ? hasFiles : hasLocalFiles);
    }

    string get_displayName() {
        return path.Replace(TmGameFolder, "");
    }

    bool get_exists() {
        return _exists;
    }
}

class ReplayFile {
    string path;
    private bool _exists;
    string fileName;
    bool isReplay;
    bool isGhost;

    bool hasLoadedGhosts = false;
    bool loadComplete = false;
    MwFastBuffer<CGameGhostScript@> ghosts = MwFastBuffer<CGameGhostScript@>();

    ReplayFile(const string &in _path) {
        path = _path.Replace("\\", "/");
        _exists = IO::FileExists(path);
        auto parts = path.Split("/");
        fileName = parts[parts.Length - 1];
        isReplay = fileName.ToLower().EndsWith(".replay.gbx");
        isGhost = fileName.ToLower().EndsWith(".ghost.gbx");
    }

    void LoadGhostsAsync() {
        hasLoadedGhosts = true;
        startnew(CoroutineFunc(this.LoadGhostsSync));
    }

    void LoadGhostsSync() {
        if (!exists) return;
        auto DataFileMgr = GetDataFileMgr(GetApp());  // does this work better for review?
        auto resp = DataFileMgr.Replay_Load(this.path);
        while (resp.IsProcessing) yield();
        if (resp.HasFailed) {
            warn("Loading ghosts from " + this.path + " failed: " + resp.ErrorDescription);
        } else {
            this.ghosts = resp.Ghosts;
            this.loadComplete = true;
        }
    }

    string get_displayName() {
        return path.Replace(TmGameFolder, "");
    }

    string get_shortPath() {
        return path.Replace(TmGameFolder + "Replays/", "");
    }

    bool get_exists() {
        return _exists;
    }
}

bool IsReplayOrGhostFile(const string &in p) {
    return p.ToLower().EndsWith(".replay.gbx")
        || p.ToLower().EndsWith(".ghost.gbx");
}
