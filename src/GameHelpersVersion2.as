CGamePlaygroundClientScriptAPI@ GetPlaygroundClientScriptAPISync(CGameCtnApp@ app) {
    try {
        return cast<CTrackMania>(app).Network.PlaygroundClientScriptAPI;
    } catch {}
    return null;
}
