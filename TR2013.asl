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
	int skippableCutscene	: 0x176F070; //1065353216 for when not skippable and when in main menu, 0 for when it is skippable and when your loading it stays at 1065353216
    bool isLoading			: 0x1E33250; //True or False, True is 1 false is 0 
	
	string50 level			: 0x1E28EA8; //detects level change
    float Percentage        : 0x01D34A40, 0x24; //isint always up to date with the progression in the map an not everything makes it change
	
	byte newGameSelect		: 0x0211FEAC, 0x100, 0x24; //changes number base off the difficulty you choose 0 for easy(WHICH IS NOT ALLOWED EVER!) 1 for normal which is deult and 2 for hard this is how the newgameselect works DO NOT CHANGE!!!!
	int saveSlot			: 0x0211FEAC, 0xFC, 0x24; //literally the saveslot number
	
	int Grenadelauncherammo : 0x2120684; // most of the time its null but eventually changes to -1 when ur close to getting the grenade launcher
    int bowAmmo				: 0x21203F0; //bowAmmo
}

//[17892] 38543360 
state("TombRaider", "Steam_Current")
{
    bool FMV				: "binkw32.dll", 0x2830C;
    int cutsceneValue		: 0x20C97C0; 
	int skippableCutscene	: 0x1713B30;
    bool isLoading			: 0x1DDBC51; //0x1CF7FE0 original
	
	string50 level			: 0x1DC18D8;
    float Percentage        : 0x01CDD540, 0x24; 
	
	byte newGameSelect		: 0x020CF83C, 0x100, 0x24; 
	int saveSlot			: 0x020CF83C, 0xFC, 0x24; 
	
   int Grenadelauncherammo : 0x01F7B6D4, 0x20, 0x8;
    int bowAmmo				: 0x20CFD80; 
}

//epic case number [17892] 38535168 
state("TombRaider", "Epic")
{
	bool FMV				: "binkw32.dll", 0x2830C; 
    int cutsceneValue		: 0x20C7DBC; 
	int skippableCutscene	: 0x1712500; 
    bool isLoading			: 0x1CF6960; //1CF6960 original
	
	string50 level			: 0x1DBF218;
    float Percentage        : 0x01CDBEC4, 0x24;
	
	byte newGameSelect		: 0x020CDF00, 0x100, 0x24;
	int saveSlot			: 0x020CDF00, 0xFC, 0x24;
	
	int Grenadelauncherammo : 0x01F79DA4, 0x20, 0x8;
    int bowAmmo				: 0x20CE450;
}

//MS case number [29008] 60145664 
state("TombRaider", "MS")
{
	bool FMV				: "binkw32.dll", 0x314CC; 
    int cutsceneValue		: 0x34E4E18; //its very weird first cutscene isint 712 for whatever reason but final cutscene is.
	int skippableCutscene	: 0x190A7BC; 
    bool isLoading			: 0x23C5A80; 
	
	string50 level			: 0x33E5190;
    float Percentage        : 0x033B05D0, 0x24; 
	
	byte newGameSelect		: 0x034EC6B8, 0x218, 0x28;
	int saveSlot			: 0x034EC6B8, 0x210, 0x28;
    
    int Grenadelauncherammo : 0x0220A210, 0x40, 0xC;
    int bowAmmo				: 0x34ECD6C;
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.Settings.CreateFromXml("Components/TR2013.Settings.xml");
    vars.CompletedSplits = new HashSet<string>();

    vars.Helper.AlertLoadless();
    
    // Initialize percentage variable
    float Percentage = 0.0f;
    
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
    
    if (string.IsNullOrEmpty(current.level))
    {
        current.level = old.level;
    }
    
    if(settings["percentage display"])
    {
    // Access percentage value
    current.Percentage = Math.Round(current.Percentage, 2);

    vars.SetTextComponent("Percentage Completion", "N/A");
    if (current.Percentage != null)
        vars.SetTextComponent("Percentage Completion", current.Percentage + "%");
    }


   //print("version: " + version);
    //print(modules.First().ModuleMemorySize.ToString());
    //print("Jack;" + " CurrentCutscene:" + current.cutsceneValue + " OldCutscene:" + old.cutsceneValue  + " level:" + current.level + "saveSlot:" + current.saveSlot);
    //print("isgametimepaused: " + vars.TimerIsGameTimePaused);

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
	
	//Wolves, splits when FMV at campfire ends
	if(current.level == "vh_main" && !vars.CompletedSplits.Contains("Wolves") && current.cutsceneValue == 521 && old.cutsceneValue == 521 && settings["Wolves"])
	{
		vars.CompletedSplits.Add("Wolves");
		return true;
	}

    //Grenade launcher, splits when getting the grenade launcher
    if (current.Grenadelauncherammo > 1 && !vars.CompletedSplits.Contains("Grenade launcher") && old.cutsceneValue == 521 && settings["Grenade launcher"] )
    {
        vars.CompletedSplits.Add("Grenade launcher");
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
    
    //Dr James Whitman, Splits during Whitmans death cutscene
    if (current.level == "chasm_entrance" && !vars.CompletedSplits.Contains("Dr James Whitman") && current.cutsceneValue == 520 && settings["Dr James Whitman"])
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
	} 
	else if (current.bowAmmo == -1 || current.isLoading || current.FMV)
	{
    		return true;
	} else
	{
   		return false;
	}

	//return current.cutsceneValue == 520 || current.bowAmmo == -1 || current.isLoading || current.FMV;
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
