///////////////////////////////////////////////////
//
// Attract-Mode Frontend - LEDServer plugin
//
///////////////////////////////////////////////////
//
// Usage: 
//
// 1.  Install LED Server on your system: https://github.com/csantill/LEDMatrixServer
//
// 2.  Copy this file to the "plugins" directory of your Attract-Mode 
//     configuration.
//
// 3.  Run Attract-Mode and enter configuration mode.  Configure the
//      plugin with the path to the LED Server Web server.
//
///////////////////////////////////////////////////

//
// The UserConfig class identifies plugin settings that can be configured
// from Attract-Mode's configuration menu
//
class UserConfig </ help="Integration plug-in for use with LED Server : https://github.com/csantill/LEDMatrixServer" /> {
	</ label="Server Address", help="Url of LED Webserver", order=1 />
	LEDserver="http://LEDServer:5000/";

	</ label="Emulator Color", help="Default color for emulator", order=2, options="red1, yellow1, violet, aqua,darkslateblue" />
	emulatorcolor="red1";


	</ label="Welcome Message", help="Message to Display on startup", order=3 />
	LEDwelcome="Welcome to my Arcade";

	</ label="Goodbye Message", help="Message to Display on exit", order=4 />
	LEDgoodbye="Play again soon";
}


local settings = {
   delay_timer = 0,
   led_updated = false,
   display_delay = 2000,
   message = ""
}
local config=fe.get_config(); // get the plugin settings configured by the user

fe.add_ticks_callback(this, "on_tick");
fe.add_transition_callback( "LEDServer_plugin_transition" );

function LEDServerSendMessageToServer(message)
{
    local commandLine = @"-H ""Content-type: application/json "" --request POST " + 
	config["LEDserver"] + @"led --data '"+message+@"'" ;
 //   print(commandLine +"\n");
	system("curl "+commandLine);
	settings.led_updated = false;
	//fe.plugin_command_bg ("curl" , commandLine);
}

function LEDServerBuildJson(emul,emulcolor,title,titlecolor)
{ 
	local q = "\"";
    local q2 = "\"";
	local mess1 = q + "emulator" + q;
	local mess2 =  q + emul + q ;
	local message = "{" + mess1 +  ":"+ mess2 + "," + q + "game" + q + ":" + q + title + q + "}" ;
	return message
}
// For debuggin purposes
function when(w) {
	switch (w) {
	case 0:
		return "StartLayout";
	case 1:
		return "EndLayout";
	case 2:
		return "ToNewSelection";
	case 3:
		return "FromOldSelection";
	case 4:
		return "ToGame";
	case 5:
		return "FromGame";
	case 6:
		return "ToNewList";
	case 7:
		return "EndNavigation";
	case 100:
		return "OnDemand";
	case 101:
		return "Always";
	}
}

function on_tick(tick_time) {
   if ( settings.led_updated && tick_time - settings.delay_timer >= settings.display_delay ) {
	   LEDServerSendMessageToServer(settings.message);
   }
}

function LEDServer_plugin_transition( ttype, var, ttime ) {

	if ( ScreenSaverActive )
		return false;

    local message="";

	//print("vent " +when(ttype)+"\n");

	switch ( ttype )
	{
	case Transition.StartLayout:
		if (( var == FromTo.Frontend ) && ( config["LEDwelcome"].len() > 0 ))
			{
				settings.delay_timer = fe.layout.time;
				settings.message  = LEDServerBuildJson(config["LEDwelcome"],"aqua",config["LEDwelcome"],"red1");
				LEDServerSendMessageToServer(settings.message );
            }

		break;

	case Transition.EndLayout:
		if (( var == FromTo.Frontend ) && ( config["LEDgoodbye"].len() > 0 ))
        {
			settings.delay_timer = fe.layout.time;
			settings.message  = LEDServerBuildJson(config["LEDgoodbye"],"aqua",config["LEDgoodbye"],"red1");
			LEDServerSendMessageToServer(settings.message );
        }
		break;

	case Transition.ToNewSelection:
	case Transition.ToNewList:
		local title =  fe.game_info( Info.Title,var );
		if (title.len() > 0)
		{
			local emulator =  fe.game_info( Info.Emulator,var ) + " " + fe.game_info(Info.System,var);
			if ( emulator.len() > 0 )
			{
				settings.message = LEDServerBuildJson(emulator,"aqua",title,"red1");
				settings.delay_timer = fe.layout.time;
				settings.led_updated = true;
			}
		}
		break;
	}

	return false; // must return false
}
