CGameDataFileManagerScript@ GetDataFileMgr(CGameCtnApp@ app) {
    CGameDataFileManagerScript@ dataFileMgr = GetDataFileMgrSync(app);
    while (dataFileMgr is null) {
        yield();
        @dataFileMgr = GetDataFileMgrSync(app);
    }
    return dataFileMgr;
}
CGameDataFileManagerScript@ GetDataFileMgrSync(CGameCtnApp@ app) {
    try {
        return cast<CTrackMania>(app).MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr;
    } catch {}
    return null;
}

CGamePlaygroundClientScriptAPI@ GetPlaygroundClientScriptAPI(CGameCtnApp@ app) {
    CGamePlaygroundClientScriptAPI@ ret = GetPlaygroundClientScriptAPISync(app);
    while (ret is null) {
        yield();
        @ret = GetPlaygroundClientScriptAPISync(app);
    }
    return ret;
}

CGamePlaygroundClientScriptAPI@ GetPlaygroundClientScriptAPISync(CGameCtnApp@ app) {
    try {
        return cast<CTrackMania>(app).Network.PlaygroundClientScriptAPI;
    } catch {}
    return null;
}

string GetPlayerName(CGameCtnApp@ app) {
    try {
        return cast<CTrackMania>(app).MenuManager.MenuCustom_CurrentManiaApp.LocalUser.Name;
    } catch {}
    return "";
}
