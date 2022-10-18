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

    ReplayDirectory(const string &in dirPath) {
        _exists = IO::FolderExists(dirPath);
        path = dirPath;
        if (path.EndsWith("/")) path.SubStr(0, path.Length - 1);
        contents = IO::IndexFolder(path, false);
        yield();
        auto parts = dirPath.Split("/");
        folderName = parts[parts.Length - 1];
        for (uint i = 0; i < contents.Length; i++) {
            auto childPath = contents[i];
            if (IO::FileExists(childPath) && IsReplayOrGhostFile(childPath)) {
                files.InsertLast(ReplayFile(childPath));
            } else if (IO::FolderExists(childPath)) {
                subdirs.InsertLast(ReplayDirectory(childPath));
            }
        }
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
    private bool exists;
    string fileName;
    ReplayFile(const string &in _path) {
        path = _path;
        exists = IO::FileExists(_path);
        auto parts = _path.Split("/");
        fileName = parts[parts.Length - 1];
    }
}

bool IsReplayOrGhostFile(const string &in p) {
    return p.ToLower().EndsWith(".replay.gbx")
        || p.ToLower().EndsWith(".ghost.gbx");
}
