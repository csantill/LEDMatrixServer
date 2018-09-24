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
class UserConfig </ help="Integration plug-in for use with LED Server Speech Synthesizer: http://LED Server.sourceforge.net" /> {
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
	fe.plugin_command_bg ("curl -H \"Content-type: application/json\" --request POST " + 
	config["LEDserver"] + "led --data '"+message+"'" );
}

function LEDServerBuildJson(emul,emulcolor,title,titlecolor)
{ 
	q = "\"";
	mess1 = q + "emulator" + q;
	mess2 =  q+ emul + q ;
	message = "{" + mess1 +  ":"+ q+emulator+q+ "," +q+ "game" +q+ ":" +q+title+q+ "}" ;
	return message
}

function LEDServer_plugin_transition( ttype, var, ttime ) {

	if ( ScreenSaverActive )
		return false;

	switch ( ttype )
	{
	case Transition.StartLayout:
		if (( var == FromTo.Frontend ) && ( config["welcome"].len() > 0 ))
			
			message = LEDServerBuildJson(config["welcome"],"aqua",config["welcome"],"red1");
			LEDServerSendMessageToServer(message);

		break;

	case Transition.EndLayout:
		if (( var == FromTo.Frontend ) && ( config["goodbye"].len() > 0 ))
			message = LEDServerBuildJson(config["goodbye"],"aqua",config["welcome"],"red1");
			LEDServerSendMessageToServer(message);
		break;

	case Transition.ToGame:
		local title =  fe.game_info( Info.Title );
		local emulator =  fe.game_info( Info.Emulator ) + " " + fe.game_info(Info.system);
		

		if ( title.len() > 0 )
			message = LEDServerBuildJson(emulator,"aqua",title,"red1");
			LEDServerSendMessageToServer(message);
			break;
	}

	return false; // must return false
}
