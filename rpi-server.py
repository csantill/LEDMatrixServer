import os
import random
import sys
from PIL import ImageFont
from PIL import Image
from PIL import ImageDraw
import color_constants as col
from flask import render_template

from flask import Flask, url_for
from flask import json
from flask import request
import subprocess

def LED_Message(text,params):
	#print(text)
	font = ImageFont.truetype("/usr/share/fonts/truetype/freefont/FreeSans.ttf", 16)
	all_text = ""	
	for text_color_pair in text:
		t = text_color_pair[0]
		all_text = all_text + t

	#print(all_text)
	width, _ = font.getsize(all_text)
	#print(width)
	im = Image.new("RGB", (width + 30, 16), "black")
	draw = ImageDraw.Draw(im)

	x = 0
	for text_color_pair in text:
			t = text_color_pair[0]
			c = text_color_pair[1]
			#print("t=" + t + " " + str(c) + " " + str(x))
			draw.text((x, 0), t, c, font=font)
			x = x + font.getsize(t)[0]
		
	im.save("/tmp/ledmessage.ppm")
	os.system("killall  -9  demo ") # kill current display process (if any)
	subprocess.Popen("sudo ./demo -D 1 /tmp/ledmessage.ppm " + params,shell=True)
#	subprocess.Popen("sudo ./demo -D 1 /tmp/ledmessage.ppm   --led-rows=16 --led-cols=32 --led-chain=3",shell=True)
	#os.system("./demo -D 1 test.ppm --led-pwm-lsb-nanoseconds=100 --led-show-refresh  --led-rows=16 --led-cols=32 --led-chain=3")
	#subprocess.Popen("sudo ./demo -D 1 test.ppm --led-pwm-lsb-nanoseconds=100 --led-show-refresh  --led-rows=16 --led-cols=32 --led-chain=3",shell=True)
	sys.stdout.flush()

def randomColor():
	key = random.choice(col.colors.keys())
	color =col.colors[key]
	return color

app = Flask(__name__)

@app.route('/')
def api_root():
	return render_template('main.html', name="main")

@app.route('/emu')
def api_emu():
	return render_template('index.html', name="index")
# test from CURL	
#curl -H "Content-type: application/json" --request POST http://192.168.1.220:5000/led --data '{"emulator:"Mame"}'

@app.route('/ledmessage',methods=['POST'])
def api_ledmessage():
	if request.headers['Content-Type'] == 'application/x-www-form-urlencoded':
		Message = request.form
		emulator = str(Message['message'])
		GPIO = str(Message['GPIO'])
		color = randomColor()
		text_message = ((emulator, color	),("   ", (0, 0, 0)),(emulator, col.AQUA	))
		params = "--led-rows=16 --led-cols=32 --led-chain=3 --led-gpio-mapping=" + GPIO
		print(params)
		LED_Message(text_message,params)
		return render_template('main.html', name="main")


#curl -H "Content-type: application/json" --request POST http://192.168.1.220:5000/led --data '{"emulator":"MAME","game":"space"}'^

@app.route('/led',methods=['POST'])
def api_led():
	# print("in here")
	# print(request)
	# print("type :"  + request.headers['Content-type'])
	if request.headers['Content-Type'] == 'application/json':
		jsonMessage = request.get_json(silent=True)
		#print(jsonMessage)
		text1 = str(jsonMessage['text1'])
		text2 = str(jsonMessage['text2'])
		color1 = str(jsonMessage['color1'])
		color2 = str(jsonMessage['color2'])

		GPIO = str(jsonMessage['GPIO'])
		LEDChain = str(jsonMessage['LEDChain'])
		LEDRows = str(jsonMessage['LEDRows'])
		LEDCols = str(jsonMessage['LEDCols'])
		LEDBrightness = str(jsonMessage['LEDBrightness'])

		params = (" --led-rows=" + LEDRows + " --led-cols=" + LEDCols + " --led-chain=" +LEDChain +
		 		  " --led-gpio-mapping=" + GPIO + " --led-brightness=" + LEDBrightness)
		#print(params)
		#print(text1)
		#print(text2)
		#print(color1)
		#print(color2)
		text_message = ((text1, col.colors[color1]	), ("   ", (0, 0, 0)), (text2, col.colors[color2]))
		#print(text_message)
		LED_Message(text_message,params)
		return "OK"	

if __name__== '__main__':
	app.run(host='0.0.0.0')


