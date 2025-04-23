// c 2025-04-23
// m 2025-04-23

const string  pluginColor = "\\$88F";
const string  pluginIcon  = Icons::ClockO;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

Map@[] maps;

void Main() {
    auto App = cast<CTrackMania>(GetApp());

    for (uint i = 0; i < App.ChallengeInfos.Length; i++) {
        CGameCtnChallengeInfo@ map = App.ChallengeInfos[i];
        if (map !is null && map.MapUid != "" && !map.Name.Contains("VR"))
            maps.InsertLast(Map(map));
    }
}

void Render() {
    if (false
        || !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(pluginTitle, S_Enabled, UI::WindowFlags::AlwaysAutoResize))
        RenderWindow();
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void RenderWindow() {
    for (uint i = 0; i < maps.Length; i++) {
        Map@ map = maps[i];

        if (i % 10 != 0)
            UI::SameLine();

        if (i < 40) {  // white
            UI::PushStyleColor(UI::Col::Button, vec4(1.0f));
            UI::PushStyleColor(UI::Col::Text, vec4(vec3(), 1.0f));
        } else if (i < 80)  // green
            UI::PushStyleColor(UI::Col::Button, vec4(0.0f, 0.8f, 0.3f, 1.0f));
        else if (i < 120)  // blue
            UI::PushStyleColor(UI::Col::Button, vec4(0.0f, 0.3f, 0.8f, 1.0f));
        else if (i < 160)  // red
            UI::PushStyleColor(UI::Col::Button, vec4(0.8f, 0.0f, 0.0f, 1.0f));
        else  // black
            UI::PushStyleColor(UI::Col::Button, vec4(vec3(0.2f), 1.0f));

        if (UI::Button("#" + map.name))
            map.Play();

        UI::PopStyleColor(i < 40 ? 2 : 1);
    }
}

class Map {
    string name;
    string path;

    Map(CGameCtnChallengeInfo@ map) {
        name = map.Name;
        path = map.FileName;
    }

    void Play() {
        startnew(CoroutineFunc(PlayAsync));
    }

    void PlayAsync() {
        print("loading map " + name + " from path " + path);

        auto App = cast<CTrackMania>(GetApp());
        App.BackToMainMenu();
        while (!App.ManiaTitleFlowScriptAPI.IsReady)
            yield();
        App.ManiaTitleFlowScriptAPI.PlayMap(path, "TMC_CampaignSolo", "");
        while (!App.ManiaTitleFlowScriptAPI.IsReady)
            yield();
    }
}
