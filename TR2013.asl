/*
 * Tomb Raider (2013) autosplitter and load remover
 * Original load remover and IGT pausing by Dread
   * Updated load remover, autosplitter and settings by Cadarev (@CadarevElry, Discord: Cadarev#8544) with help from Toxic_TT and rythin_sr.
   * Updated for Epic Games Store, latest Steam version, & Microsoft store by TpRedNinja and DeathHound.
 * Thank you to clove for additional testing.
 */

//build743 case number [17892] 38739968 
state("TombRaider", "Steam_743.0")
{
    bool FMV				: "binkw32.dll", 0x2830C; //Works on all versions but MS(Microsoft store)
    int cutsceneValue		: 0x211AB5C; //712 first cutscene then 520 then 8 for dragging cutscene, 520 in most cutscenes but 712 during final cutscene.
    bool isLoading			: 0x1E33250; //True or False, True is 1 false is 0
    int Camp                : 0x10E7780; //True or False, True is 1 false is 0
	
	string50 level			: 0x1E28EA8; //detects level change
    float Percentage        : 0x01D34A40, 0x24; //isn't always up to date with the progression in the map an not everything makes it change
	
	byte newGameSelect		: 0x0211FEAC, 0x100, 0x24; //changes number base off the difficulty you choose 0 for easy(WHICH IS NOT ALLOWED EVER!) 1 for normal which is default and 2 for hard this is how the NewGameSelect works DO NOT CHANGE!!!!
	int saveSlot			: 0x0211FEAC, 0xFC, 0x24; //literally the save slot number
	
	int GLA                 : 0x2120684; // most of the time its null but eventually changes to -1 when ur close to getting the grenade launcher
    int bowAmmo				: 0x21203F0; //bowAmmo
    int Ammo                : 0x2120670; //All ammo's
}

//[17892] 38543360 
state("TombRaider", "Steam_Current")
{
    bool FMV				: "binkw32.dll", 0x2830C;
    int cutsceneValue		: 0x20C97C0; 
    bool isLoading			: 0x1DDBC51; //0x1CF7FE0 original
    int Camp                : 0x107DD60; 
	
	string50 level			: 0x1DC18D8;
    float Percentage        : 0x01CDD540, 0x24; 
	
	byte newGameSelect		: 0x020CF83C, 0x100, 0x24; 
	int saveSlot			: 0x020CF83C, 0xFC, 0x24; 
	
    int GLA                 : 0x20D0014;
    int bowAmmo				: 0x20CFD80; 
    int Ammo                : 0x20D0000;
}

//epic case number [17892] 38535168 
state("TombRaider", "Epic")
{
	bool FMV				: "binkw32.dll", 0x2830C; 
    int cutsceneValue		: 0x20C7DBC; 
    bool isLoading			: 0x1CF6960;
    int Camp                : 0x107C870; 
	
	string50 level			: 0x1DBF218;
    float Percentage        : 0x01CDBEC4, 0x24;
	
	byte newGameSelect		: 0x020CDF00, 0x100, 0x24;
	int saveSlot			: 0x020CDF00, 0xFC, 0x24;
	
	int GLA                 : 0x20CE6E4;
    int bowAmmo				: 0x20CE450;
    int Ammo                : 0x20CE6D0;
}

//MS case number [29008] 60145664 
state("TombRaider", "MS")
{
	bool FMV				: "binkw32.dll", 0x314CC; 
    int cutsceneValue		: 0x34E4E18; //its very weird first cutscene isn't 712 for whatever reason but final cutscene is.
    bool isLoading			: 0x23C5A80;
    int Camp                : 0x25F87FC;
	
	string50 level			: 0x33E5190;
    float Percentage        : 0x033B05D0, 0x24; 
	
	byte newGameSelect		: 0x034EC6B8, 0x218, 0x28;
	int saveSlot			: 0x034EC6B8, 0x210, 0x28;
    
    int GLA                 : 0x34ED0DC;
    int bowAmmo				: 0x34ECD6C;
    int Ammo                : 0x34ED0C8;
}

startup
{
    // load in xml file for settings as well as asl-help and making manual settings
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.Settings.CreateFromXml("Components/TR2013.Settings.xml");
    settings.Add("COL", false, "Collectibles");
    settings.SetToolTip("COL", "Collectibles settings, Select this for 100% runs. \nThis will enable the watchers for the collectibles");
    settings.Add("percentage display", false);


    // variables
    vars.Collectibles = new Dictionary<string, Dictionary<string, List<int>>>{
        {"Costal Forest", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x810, 3}},
            {"Documents", new List<int>{0x814, 5}},
            {"GPS", new List<int>{0x828, 5}},
            {"Map", new List<int>{0x82C, 1}}
            }
        },
        {"Mountain Temple", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x960, 2}},
            {"Documents", new List<int>{0x964, 2}},
            {"GPS", new List<int>{0x978, 2}},
            {"Map", new List<int>{0x97C, 1}}
            }
        },
        {"Mountain Village", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0xAB0, 6}},
            {"Documents", new List<int>{0xAB4, 7}},
            {"Tombs", new List<int>{0xAC4, 2}},
            {"GPS", new List<int>{0xAC8, 15}}
            }
        },
        {"Base Approach", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x880, 2}},
            {"GPS", new List<int>{0x898, 2}}
            }
        },
        {"Mountain Base", new Dictionary<string, List<int>>{
            {"Documents", new List<int>{0x7A4, 3}},
            {"GPS", new List<int>{0x7B8, 2}}
            }
        },
        {"Base Exterior", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x8F0, 2}},
            {"Documents", new List<int>{0x8F4, 2}},
            {"GPS", new List<int>{0x908, 1}},
            {"Map", new List<int>{0x90C, 1}}
            }
        },
        {"Shanty Town", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0xA40, 7}},
            {"Documents", new List<int>{0xA44, 5}},
            {"Tombs", new List<int>{0xA54, 2}},
            {"GPS", new List<int>{0xA58, 15}}
            }
        },
        {"Geothermal Caverns", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x730, 3}},
            {"Documents", new List<int>{0x734, 3}},
            {"GPS", new List<int>{0x748, 5}},
            {"Map", new List<int>{0x74C, 1}}
            }
        },
        {"Summit Forest", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x6C0, 3}},
            {"Documents", new List<int>{0x6C4, 2}},
            {"Tombs", new List<int>{0x6D4, 1}},
            {"GPS", new List<int>{0x6D8, 5}}
            }
        },
        {"Shipwreck Beach", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x9D0, 6}},
            {"Documents", new List<int>{0x9D4, 4}},
            {"Tombs", new List<int>{0x9E4, 2}},
            {"GPS", new List<int>{0x9E8, 15}}
            }
        },
        {"Chasm Shrine", new Dictionary<string, List<int>>{
            {"Relics", new List<int>{0x570, 3}},
            {"Documents", new List<int>{0x574, 3}},
            {"Map", new List<int>{0x58C, 1}}
            }
        }
    };

    foreach(var item in vars.Collectibles)
    {
        settings.Add(item.Key, false, item.Key, "COL");
        foreach(var item2 in item.Value)
        {
          settings.Add(item.Key + item2.Key + "Each", false, item2.Key + " (Each)", item.Key);
          settings.Add(item.Key + item2.Key + "All", false, item2.Key + " (All)", item.Key);
        }
    }
    
    vars.CompletedSplits = new HashSet<string>();
    
    // set text taken from Poppy Playtime C2
    // to display the text associated with this script aka current percentage
    Action<string, string> SetTextComponent = (id, text) => {
        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
        if (textSetting == null)
        {
            var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
            var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
            timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

            textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
            textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
        }

        if (textSetting != null)
            textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
    };
    vars.SetTextComponent = SetTextComponent;

    

}

init
{
    int CollectibleBase = 0x0;
    timer.IsGameTimePaused = false;
    vars.TimerIsGameTimePaused = timer.IsGameTimePaused;

    switch (modules.First().ModuleMemorySize) { //Detects which version of the game is being played
        default:
            version = "Steam_743.0";
            CollectibleBase = 0x0211BF60;
            break;
        case (38543360):
            version = "Steam_Current";
            CollectibleBase = 0x020CABC0;
            break;
        case (38535168):
            version = "Epic";
            CollectibleBase = 0x020C92A0;
            break;
        case (60141568):
            version = "MS";
            CollectibleBase = 0x034E7100;
            break;
    }
    vars.version = version;

    // defining collectibles offsets
    if (version == "MS")
    {
        vars.Collectibles = vars.Collectibles = new Dictionary<string, Dictionary<string, List<int>>>{
            {"Costal Forest", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x818, 3}},
                {"Documents", new List<int>{0x81C, 5}},
                {"GPS", new List<int>{0x830, 5}},
                {"Map", new List<int>{0x834, 1}}
                }
            },
            {"Mountain Temple", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x968, 2}},
                {"Documents", new List<int>{0x96C, 2}},
                {"GPS", new List<int>{0x980, 2}},
                {"Map", new List<int>{0x984, 1}}
                }
            },
            {"Mountain Village", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0xAB8, 6}},
                {"Documents", new List<int>{0xABC, 7}},
                {"Tombs", new List<int>{0xACC, 2}},
                {"GPS", new List<int>{0xAD0, 15}}
                }
            },
            {"Base Approach", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x888, 2}},
                {"GPS", new List<int>{0x8A0, 2}}
                }
            },
            {"Mountain Base", new Dictionary<string, List<int>>{
                {"Documents", new List<int>{0x7AC, 3}},
                {"GPS", new List<int>{0x7C0, 2}}
                }
            },
            {"Base Exterior", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x8F8, 2}},
                {"Documents", new List<int>{0x8FC, 2}},
                {"GPS", new List<int>{0x910, 1}},
                {"Map", new List<int>{0x914, 1}}
                }
            },
            {"Shanty Town", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0xA48, 7}},
                {"Documents", new List<int>{0xA4C, 5}},
                {"Tombs", new List<int>{0xA5C, 2}},
                {"GPS", new List<int>{0xA60, 15}}
                }
            },
            {"Geothermal Caverns", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x738, 3}},
                {"Documents", new List<int>{0x73C, 3}},
                {"GPS", new List<int>{0x750, 5}},
                {"Map", new List<int>{0x754, 1}}
                }
            },
            {"Summit Forest", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x6C8, 3}},
                {"Documents", new List<int>{0x6CC, 2}},
                {"Tombs", new List<int>{0x6DC, 1}},
                {"GPS", new List<int>{0x6E0, 5}}
                }
            },
            {"Shipwreck Beach", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x9D8, 6}},
                {"Documents", new List<int>{0x9DC, 4}},
                {"Tombs", new List<int>{0x9EC, 2}},
                {"GPS", new List<int>{0x9F0, 15}}
                }
            },
            {"Chasm Shrine", new Dictionary<string, List<int>>{
                {"Relics", new List<int>{0x578, 3}},
                {"Documents", new List<int>{0x57C, 3}},
                {"Map", new List<int>{0x594, 1}}
                }
            }
        };
    }

    // make watchers for collectibles
    vars.Watchers = new MemoryWatcherList();

    foreach(var item in vars.Collectibles){
      foreach(var item2 in item.Value){
        vars.Watchers.Add(new MemoryWatcher<int>(new DeepPointer(CollectibleBase, item2.Value[0])){Name = item.Key + item2.Key});}}

}

update
{
    current.Percentage = Math.Round(current.Percentage, 2);

    if(settings["COL"])
    {
        vars.Watchers.UpdateAll(game);
    }
        
    if (string.IsNullOrEmpty(current.level))
    {
        current.level = old.level;
    }
        
    if(settings["percentage display"])
    {
        
        vars.SetTextComponent("Percentage Completion", "N/A");
        if (current.Percentage != null)
        {
            vars.SetTextComponent("Percentage Completion", current.Percentage + "%");
        }
    }

    //print("version: " + version);
    //print(modules.First().ModuleMemorySize.ToString());
    //print("IsGameTimePaused: " + vars.TimerIsGameTimePaused);

}

start
{
    // Starts timer when opening Fmv starts (after choosing difficulty)
    if (old.level != "cine_chaos_beach" && current.level == "cine_chaos_beach" && current.saveSlot >= 1 )
    {
        timer.Run.Offset = TimeSpan.FromSeconds(0);
        return true;
    }

    // Starts timer when loading the first checkpoint from save slot one and sets the starting time to 1:46.
    if (old.isLoading && !current.isLoading && current.level == "survival_den97" && current.saveSlot >= 1)
    { 
        timer.Run.Offset = TimeSpan.FromSeconds(106);
        return true;
    }

    if (vars.version == "MS")
    {
        // Starts timer when opening Fmv starts (after choosing difficulty)
        if (old.level != "cine_chaos_beach" && current.level == "cine_chaos_beach")
        {
            timer.Run.Offset = TimeSpan.FromSeconds(0);
            return true;
        }

        // Starts timer when loading the first checkpoint from save slot one and sets the starting time to 1:46.
        if (old.isLoading && !current.isLoading && current.level == "survival_den97")
        { 
            timer.Run.Offset = TimeSpan.FromSeconds(106); // 1* 60 + 46 = 106 or 1:46
            return true;
        }
   }

}

split
{
    // normal splits
    if (old.level != current.level) // Split on level changing
    {
        string leveltransition = old.level + "_" + current.level;
        if (settings.ContainsKey(leveltransition) && settings[leveltransition] && !vars.CompletedSplits.Contains(leveltransition))
        {
            vars.CompletedSplits.Add(leveltransition);
            return true;
        }
    }

    // collectible splits
    if(settings["COL"])
    {
        foreach(var item in vars.Collectibles)
        {
            foreach(var item2 in item.Value)
            {
                var V = vars.Watchers[item.Key + item2.Key];
                if(V.Current != V.Old)
                {
                    string allKey = item.Key + " " + item2.Key + "-" + item2.Value[0].ToString();
                    string eachKey = item.Key + " " + item2.Key + "-" + V.Current.ToString();
                    if(settings[item.Key + item2.Key + "All"])
                    if(V.Current == item2.Value[1])
                    {
                        vars.CompletedSplits.Add(allKey);
                        print("Collected all collectibles of type '" + item2.Key + "' in '" + item.Key + "'");
                        return true;
                    }
                    else
                        return false;
                    if(settings[item.Key + item2.Key + "Each"])
                    {
                        vars.CompletedSplits.Add(eachKey);
                        print("Collected collectible of type '" + item2.Key + "' in '" + item.Key + "'");
                        return true;
                    }
                }
            }
        }
    }

    var splits1 = new List<Tuple<string, string, int>>()
    {
        new Tuple<string, string, int>("vh_main", "Wolves", 521),
        new Tuple<string, string, int>("ww2sos_map_room", "Ambush Room", 520),
        new Tuple<string, string, int>("ma_puzzle", "Bell Cutscene", 520),
        new Tuple<string, string, int>("sb_15", "Goaliath", 520),
        new Tuple<string, string, int>("sb_16", "Mirror", 520),
        new Tuple<string, string, int>("sb_20", "Alex who?", 520),
        new Tuple<string, string, int>("sb_05", "Book", 520),
        new Tuple<string, string, int>("si_25_tomb", "Samurai", 520),
        new Tuple<string, string, int>("qt_the_ritual", "Mathias", 712)
    };

    foreach (var split in splits1)
    {
        if (current.level == split.Item1 && current.cutsceneValue == split.Item3 && old.cutsceneValue != split.Item3 && settings[split.Item2] && !vars.CompletedSplits.Contains(split.Item2))
        {
            vars.CompletedSplits.Add(split.Item2);
            return true;
        }
    }

    var splits2 = new List<Tuple<string, string, int, float>>()
    {
        Tuple.Create("vh_main", "Chimney", 520, 8.0f),
        Tuple.Create("vh_main", "Loss", 520, 19.72f),
        Tuple.Create("bh_beach_hub", "Where's Alex", 520, 40.14f),
        Tuple.Create("bh_beach_hub", "Compound bow", 520, 42.14f),
        Tuple.Create("bh_beach_hub", "Tools", 520, 46.83f),
    };

    foreach (var split in splits2)
    {
        if(current.level == split.Item1 && current.cutsceneValue == split.Item3 && current.Percentage >= split.Item4 && !vars.CompletedSplits.Contains(split.Item2) && settings[split.Item2])
        {
            vars.CompletedSplits.Add(split.Item2);
            return true;
        }
    }

// special splits
    //Bow, splits when ammo count changes to a value above 0 (ammo count is always -1 during loading screens)
    if(current.level == "ac_forest" && !vars.CompletedSplits.Contains("Bow") && current.bowAmmo > old.bowAmmo && old.bowAmmo > -1 && settings["Bow"])
    {
        vars.CompletedSplits.Add("Bow");
        return true;
    }

    //1st camp
    if(current.level == "ac_forest" && !vars.CompletedSplits.Contains("First Skill") && current.cutsceneValue == 520 && current.Camp == 0 && old.Camp == 1 && settings["First Skill"])
    {
        vars.CompletedSplits.Add("First Skill");
        return true;
    }

    //vladimir dead
    if(current.level == "mountain_climb" && !vars.CompletedSplits.Contains("VLADIMIR!") && current.cutsceneValue == 520 && (current.Ammo == 0 || (current.bowAmmo == 0  && (current.Ammo == 1 || current.Ammo == 2))) && settings["VLADIMIR!"])
    {
        vars.CompletedSplits.Add("VLADIMIR!");
        return true;
    }

    //campfire
    if(current.level == "ww2_sos_01" && !vars.CompletedSplits.Contains("CampFire") && current.cutsceneValue == 520 && old.cutsceneValue == 8 && settings["CampFire"])
    {
        vars.CompletedSplits.Add("CampFire");
        return true;
    }

    //campfire alt
    if(current.level == "ww2_sos_01" && !vars.CompletedSplits.Contains("CampFireAlt") && current.FMV && settings["CampFireAlt"])
    {
        vars.CompletedSplits.Add("CampFireAlt");
        return true;
    }

    //Grenade launcher, splits when getting the grenade launcher
    if (current.level == "ge_04" && !vars.CompletedSplits.Contains("Grenade launcher") && current.GLA == 0 && old.GLA != current.GLA && current.cutsceneValue >= 520 && settings["Grenade launcher"])
    {
        vars.CompletedSplits.Add("Grenade launcher");
        return true;
    }

    //Dr James Whitman, Splits during Whitman's death cutscene
    if (current.level == "chasm_entrance" && current.cutsceneValue == 520 && old.cutsceneValue == 8 && current.GLA > -1 && !vars.CompletedSplits.Contains("Dr James Whitman") && settings["Dr James Whitman"])
    {
        vars.CompletedSplits.Add("Dr James Whitman");
        return true;
    }
}

isLoading
{
    if(current.cutsceneValue != 8 && (current.bowAmmo == -1 || current.isLoading || current.FMV))
    {
        return true;
    } else if (current.bowAmmo == -1 || current.isLoading || current.FMV)
    {
        return true;
    } else if (current.cutsceneValue >= 520 && (current.bowAmmo == -1 || !current.isLoading || !current.FMV) && current.level != "main_menu")
    {
        return true;
    } else
    {
        return false;
    } 
}

exit
{
    timer.IsGameTimePaused = true;
    vars.TimerIsGameTimePaused = timer.IsGameTimePaused;
}

reset
{
    if (old.level == "survival_den97" && current.isLoading)
    {
        return true;
    }
}

onReset
{
    vars.CompletedSplits.Clear();
}
