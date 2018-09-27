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

local config=fe.get_config(); // get the plugin settings configured by the user

fe.add_transition_callback( "LEDServer_plugin_transition" );

function LEDServerSendMessageToServer(message)
{
    local commandLine = @"-H ""Content-type: application/json "" --request POST " + 
	config["LEDserver"] + @"led --data '"+message+@"'" ;
 //   print(commandLine +"\n");
	system("curl "+commandLine);
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
			message = LEDServerBuildJson(config["LEDwelcome"],"aqua",config["LEDwelcome"],"red1");
			LEDServerSendMessageToServer(message);
            }

		break;

	case Transition.EndLayout:
		if (( var == FromTo.Frontend ) && ( config["LEDgoodbye"].len() > 0 ))
        {
			message = LEDServerBuildJson(config["LEDgoodbye"],"aqua",config["LEDgoodbye"],"red1");
			LEDServerSendMessageToServer(message);
        }
		break;

	case Transition.ToNewSelection:
	//	local gamme = fe.game_info(Info.Name);
	//	if (gamme.len() > 0)
	//	{
    //   print(gamme + "\n" );
	//	}
    //    print("\"" + fe.game_info( Info.Name ) + "\" \""+ fe.game_info( Info.Emulator ) + "\"" );
		local title =  fe.game_info( Info.Title );
		if (title.len() > 0)
		{
			local emulator =  fe.game_info( Info.Emulator ) + " " + fe.game_info(Info.System);
			if ( emulator.len() > 0 )
			{
				message = LEDServerBuildJson(emulator,"aqua",title,"red1");
//				print(message);
				LEDServerSendMessageToServer(message);
			}
		}
		break;
	}

	return false; // must return false
}
