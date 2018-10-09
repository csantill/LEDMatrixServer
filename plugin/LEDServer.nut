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

	</ label="Game Info 1", help="Game Information Message 1", order=2, options="Game, Game + Year , Emulator, Emulator + System" />
	LEDtext1="Game";

	</ label="Text Color 1", help="Text Color 1", order=3, options="red1, yellow1, violet, aqua,darkslateblue" />
	LEDtextcolor1="red1";

	</ label="Game Info 2", help="Game Information Message 2", order=4, options="Game, Game + Year , Emulator, Emulator + System" />
	LEDtext2="Emulator";

	</ label="Text Color 2", help="Text Color 1", order=5, options="red1, yellow1, violet, aqua,darkslateblue" />
	LEDtextcolor2="violet";
	
	</ label="LED Brightness", help="LED Brightness" , order=6 />
	LEDBrightness="75";

	</ label="GPIO Mapping", help="GPIO Mapping", order=7, options="regular, adafruit-hat, adafruit-hat-pwm" />
	LEDGPIO="regular";	

	</ label="LED Chain", help="LED Chain", order=8, options="1,2,3" />
	LEDChain="3";		

	</ label="LED Rows", help="LED Rows", order=9, options="8,16,32,64" />
	LEDRows="16";		

	</ label="LED Cols", help="LED Cols", order=10, options="32,64" />
	LEDCols="32";				

	</ label="Welcome Message", help="Message to Display on startup", order=11 />
	LEDwelcome="Welcome to my Arcade";

	</ label="Goodbye Message", help="Message to Display on exit", order=12 />
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
	config["LEDserver"] + @"led --data '"+message+@"' &" ;
 //   print(commandLine +"\n");
	system("curl "+commandLine);
	settings.led_updated = false;
	//fe.plugin_command_bg ("curl" , commandLine);
}

function LEDServerBuildJson(LEDText,LEDText2)
{ 
	local q = "\"";
    local q2 = "\"";
	local mess1 =       q + "text1"         + q + ":" + q + LEDText  + q;
	local mess2 = "," + q + "text2"         + q + ":" + q + LEDText2 + q;	
	local mess3 = "," + q + "LEDBrightness" + q + ":" + q + config["LEDBrightness"] + q;
	local mess4 = "," + q + "color1"        + q + ":" + q + config["LEDtextcolor1"] + q;
	local mess5 = "," + q + "color2"        + q + ":" + q + config["LEDtextcolor2"] + q;
	local mess6 = "," + q + "GPIO"          + q + ":" + q + config["LEDGPIO"]  + q;
	local mess7 = "," + q + "LEDChain"      + q + ":" + q + config["LEDChain"] + q; 
	local mess8 = "," + q + "LEDRows"       + q + ":" + q + config["LEDRows"]  + q; 
	local mess9 = "," + q + "LEDCols"       + q + ":" + q + config["LEDCols"]  + q;

	local message = "{" + mess1 + mess2 + mess3 + mess4 + mess5 +  mess6 + mess7 + mess8 + mess9+"}" ;
	//print("\n json :"+message)
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

function getDisplayText(displayoption,offset)
{
	//Game, Game + Year , Emulator, Emulator + System
	//print("\n**"+displayoption);
	local message = "";
	if (displayoption =="Game" )
	{
		message=getgameInfo(Info.Title,offset)+ " ";
	} else 	if (displayoption =="Game + Year" )
	{
		message= getgameInfo(Info.Title,offset) + " " + getgameInfo(Info.Year,offset) ;
	} else 	if (displayoption =="Emulator" )
	{
		message= getgameInfo(Info.Emulator,offset) + " " ;

	} else 	if (displayoption =="Emulator + System" )
	{
		message= getgameInfo(Info.Emulator,offset) + " " +  getgameInfo(Info.System,offset) ;
	}
	return message;
}

function getgameInfo(info,offset) {
	local text =  fe.game_info( info, offset );
	if (text.len() > 0) 
		return text;
	return "";
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
				settings.message  = LEDServerBuildJson(config["LEDwelcome"],config["LEDwelcome"]);
				LEDServerSendMessageToServer(settings.message );
            }

		break;

	case Transition.EndLayout:
		if (( var == FromTo.Frontend ) && ( config["LEDgoodbye"].len() > 0 ))
        {
			settings.delay_timer = fe.layout.time;
			settings.message  = LEDServerBuildJson(config["LEDgoodbye"],config["LEDgoodbye"]);
			LEDServerSendMessageToServer(settings.message );
        }
		break;

	case Transition.ToNewSelection:
	case Transition.ToNewList:
		local text1= getDisplayText( config["LEDtext1"],var);
		local text2= getDisplayText( config["LEDtext2"],var);
		//print("\n**"+text1)
		//print("\n ***"+text2)
		settings.message = LEDServerBuildJson(text1,text2);
		settings.delay_timer = fe.layout.time;
		settings.led_updated = true;
		break;
	}

	return false; // must return false
}
