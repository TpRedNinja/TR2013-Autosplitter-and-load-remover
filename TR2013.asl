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
    int Camp                : 0x10E7780; //True or False, True is 1 faalse is 0
	
	string50 level			: 0x1E28EA8; //detects level change
    float Percentage        : 0x01D34A40, 0x24; //isint always up to date with the progression in the map an not everything makes it change
	
	byte newGameSelect		: 0x0211FEAC, 0x100, 0x24; //changes number base off the difficulty you choose 0 for easy(WHICH IS NOT ALLOWED EVER!) 1 for normal which is deult and 2 for hard this is how the newgameselect works DO NOT CHANGE!!!!
	int saveSlot			: 0x0211FEAC, 0xFC, 0x24; //literally the saveslot number
	
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
    int cutsceneValue		: 0x34E4E18; //its very weird first cutscene isint 712 for whatever reason but final cutscene is.
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
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.Settings.CreateFromXml("Components/TR2013.Settings.xml");
    vars.CompletedSplits = new HashSet<string>();
    vars.CutsceneCounterForrest = 0;
    vars.CutsceneCounterBaseExterior = 0;
    vars.CutsceneCounterMountainDecent = 0;


    vars.Helper.AlertLoadless();
    
    // set text taken from Poppy Platime C2
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

    settings.Add("percentage display", false);

}

init
{
    timer.IsGameTimePaused = false;
    vars.TimerIsGameTimePaused = timer.IsGameTimePaused;

    switch (modules.First().ModuleMemorySize) { //Detects which version of the game is being played
        default:
            version = "Steam_743.0";
            break;
        case (38543360):
            version = "Steam_Current";
            break;
        case (38535168):
            version = "Epic";
            break;
        case (60141568):
            version = "MS";
            break;    
    }

    vars.version = version;

}

update
{
        current.Percentage = Math.Round(current.Percentage, 2);
        
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

        if (settings["3 wolves"])
        {
            if (current.level == "ac_main" && !vars.CompletedSplits.Contains("3 wolves") && current.cutsceneValue == 520 && old.cutsceneValue == 8 && vars.CutsceneCounterForrest != 2)
            {
                vars.CutsceneCounterForrest ++;
            }
        }

        if (settings["SOS"])
        {
            if (current.level == "ww2sos_04" && !vars.CompletedSplits.Contains("SOS") && current.cutsceneValue == 520 && old.cutsceneValue != 520 && vars.CutsceneCounterBaseExterior != 3)
            {
                vars.CutsceneCounterBaseExterior ++;
            }
            
        }

        if (settings["Lara Hurt"])
        {
            if (current.level == "de_descent_to_scav_hub_connector" && !vars.CompletedSplits.Contains("Lara Hurt") && current.cutsceneValue == 520 && old.cutsceneValue != 520 && vars.CutsceneCounterMountainDecent != 2)
            {
                vars.CutsceneCounterMountainDecent ++;
            }
            
        }   

}

start
{

    
    if (vars.version != "MS")
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
            timer.Run.Offset = TimeSpan.FromSeconds(106);
            return true;
        }
   }

}

split
{
        if (old.level != current.level) // Split on level changing
        {
            string leveltransition = old.level + "_" + current.level;
            if (settings.ContainsKey(leveltransition) && settings[leveltransition] && !vars.CompletedSplits.Contains(leveltransition))
            {
                vars.CompletedSplits.Add(leveltransition);
                return true;
            }
        }

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

        //3 wolves qte
        if(current.level == "ac_main" && !vars.CompletedSplits.Contains("3 wolves") && current.cutsceneValue == 520 && vars.CutsceneCounterForrest == 2 && settings["3 wolves"])
        {
            vars.CompletedSplits.Add("3 wolves");
            return true;
        }

        /*Gate
        if(current.level == "ac_main" && !vars.CompletedSplits.Contains("Gate") && current.cutsceneValue == 520 && current.Percentage >= 6.52 && settings["Gate"])
        {
            vars.CompletedSplits.Add("Gate");
            return true;
        }*/

        //vladimir dead
        if(current.level == "mountain_climb" && !vars.CompletedSplits.Contains("VLADIMIR!") && current.cutsceneValue == 520 && (current.Ammo == 0 || (current.bowAmmo == 0  && (current.Ammo == 1 || current.Ammo == 2))) && settings["VLADIMIR!"])
        {
            vars.CompletedSplits.Add("VLADIMIR!");
            return true;
        }

        //Chimney
        if(current.level == "vh_main" && !vars.CompletedSplits.Contains("Chimney") && current.cutsceneValue == 520 && current.Percentage >= 8 && settings["Chimney"])
        {
            vars.CompletedSplits.Add("Chimney");
            return true;
        }

        //Wolves, splits when FMV at campfire ends
        if(current.level == "vh_main" && !vars.CompletedSplits.Contains("Wolves") && current.cutsceneValue == 521 && old.cutsceneValue != 521 && settings["Wolves"])
        {
            vars.CompletedSplits.Add("Wolves");
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

        //alex helping lara cutscene for sos
        if(current.level == "ww2sos_map_room" && !vars.CompletedSplits.Contains("Ambush Room") && current.cutsceneValue == 520 && settings["Ambush Room"])
        {
            vars.CompletedSplits.Add("Ambush Room");
            return true;
        }

        //sos sent
        if(current.level == "ww2sos_04" && !vars.CompletedSplits.Contains("SOS") && current.cutsceneValue == 520 && vars.CutsceneCounterBaseExterior == 3 && settings["SOS"])
        {
            vars.CompletedSplits.Add("SOS");
            return true;
        }

        //You know about loss
        if(current.level == "vh_main" && !vars.CompletedSplits.Contains("Loss") && current.cutsceneValue == 520 && current.Percentage >= 19.72 && settings["Loss"])
        {
            vars.CompletedSplits.Add("Loss");
            return true;
        }

        //Bell Cutscene
        if(current.level == "ma_puzzle" && !vars.CompletedSplits.Contains("Bell Cutscene") && current.cutsceneValue == 520 && settings["Bell Cutscene"])
        {
            vars.CompletedSplits.Add("Bell Cutscene");
            return true;
        }

        //Lara Hurt
        if(current.level == "de_descent_to_scav_hub_connector" && !vars.CompletedSplits.Contains("Lara Hurt") && current.cutsceneValue == 520 && vars.CutsceneCounterMountainDecent == 2 && settings["Lara Hurt"])
        {
            vars.CompletedSplits.Add("Lara Hurt");
            return true;
        }
        
        //Grenade launcher, splits when getting the grenade launcher
        if (current.level == "ge_04" && !vars.CompletedSplits.Contains("Grenade launcher") && current.GLA == 0 && old.GLA != current.GLA && current.cutsceneValue >= 520 && settings["Grenade launcher"])
        {
            vars.CompletedSplits.Add("Grenade launcher");
            return true;
        }

        //where's alex?
        if(current.level == "bh_beach_hub" && !vars.CompletedSplits.Contains("Where's Alex") && current.cutsceneValue == 520 && current.Percentage >= 40.14 && settings["Where's Alex"])
        {
            vars.CompletedSplits.Add("Where's Alex");
            return true;
        }

        //Compound bow
        if(current.level == "bh_beach_hub" && !vars.CompletedSplits.Contains("Compound bow") && current.cutsceneValue == 520 && current.Percentage >= 42.14 && settings["Compound bow"])
        {
            vars.CompletedSplits.Add("Compound bow");
            return true;
        }

        //Goaliath, Splits when getting rope ascender
        if (current.level == "sb_15" && !vars.CompletedSplits.Contains("Goaliath") && current.cutsceneValue == 520 && settings["Goaliath"])
        {
            vars.CompletedSplits.Add("Goaliath");
            return true;    
        }
        //Goaliath, Splits when getting rope ascender
        if (current.level == "sb_16" && !vars.CompletedSplits.Contains("Mirror") && current.cutsceneValue == 520 && settings["Mirror"])
        {
            vars.CompletedSplits.Add("Mirror");
            return true;    
        }

        //Alex who?, Splits during alex death cutscene
        if (current.level == "sb_20" && !vars.CompletedSplits.Contains("Alex who?") && current.cutsceneValue == 520 && settings["Alex who?"])
        {
            vars.CompletedSplits.Add("Alex who?");
            return true;
        }
        
        //Book, Splits during the cutscene when lara picks up the document
        if (current.level == "sb_05" && !vars.CompletedSplits.Contains("Book") && current.cutsceneValue == 520 && settings["Book"])
        {
            vars.CompletedSplits.Add("Book");
            return true;
        }
        
        //Tools
        if(current.level == "bh_beach_hub" && !vars.CompletedSplits.Contains("Tools") && current.cutsceneValue == 520 && current.Percentage >= 46.83 && settings["Tools"])
        {
            vars.CompletedSplits.Add("Tools");
            return true;
        }

        //Tools
        if(current.level == "si_25_tomb" && !vars.CompletedSplits.Contains("Samurai") && current.cutsceneValue == 520 && settings["Samurai"])
        {
            vars.CompletedSplits.Add("Samurai");
            return true;
        }

        //Dr James Whitman, Splits during Whitmans death cutscene
        if (current.level == "chasm_entrance" && !vars.CompletedSplits.Contains("Dr James Whitman") && current.cutsceneValue == 520 && old.cutsceneValue == 8 && settings["Dr James Whitman"] && current.GLA > 0)
        {
            vars.CompletedSplits.Add("Dr James Whitman");
            return true;
        }  


        //Final split
        if(current.level == "qt_the_ritual" && old.cutsceneValue != 712 && current.cutsceneValue == 712 && settings["Mathias"])
        {
            vars.CompletedSplits.Add("Mathias");
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
    vars.CutsceneCounterForrest = 0;
    vars.CutsceneCounterBaseExterior = 0;
    vars.CutsceneCounterMountainDecent = 0;
}
