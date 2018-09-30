import os
import random
from PIL import ImageFont
from PIL import Image
from PIL import ImageDraw
import color_constants as col
from flask import render_template

from flask import Flask, url_for
from flask import json
from flask import request
import subprocess



def LED_Message(text):
	print(text)
	font = ImageFont.truetype("/usr/share/fonts/truetype/freefont/FreeSans.ttf", 16)
	all_text = ""	
	for text_color_pair in text:
		t = text_color_pair[0]
		all_text = all_text + t

	print(all_text)
	width, _ = font.getsize(all_text)
	print(width)
	im = Image.new("RGB", (width + 30, 16), "black")
	draw = ImageDraw.Draw(im)

	x = 0
	for text_color_pair in text:
			t = text_color_pair[0]
			c = text_color_pair[1]
			print("t=" + t + " " + str(c) + " " + str(x))
			draw.text((x, 0), t, c, font=font)
			x = x + font.getsize(t)[0]
		
	im.save("/tmp/test.ppm")
	os.system("killall  -9  demo ")
	subprocess.Popen("sudo ./demo -D 1 /tmp/test.ppm   --led-rows=16 --led-cols=32 --led-chain=3",shell=True)
	#os.system("./demo -D 1 test.ppm --led-pwm-lsb-nanoseconds=100 --led-show-refresh  --led-rows=16 --led-cols=32 --led-chain=3")
	#subprocess.Popen("sudo ./demo -D 1 test.ppm --led-pwm-lsb-nanoseconds=100 --led-show-refresh  --led-rows=16 --led-cols=32 --led-chain=3",shell=True)


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
		color = randomColor()
		text_message = ((emulator, color	),("   ", (0, 0, 0)),(emulator, col.AQUA	))
		LED_Message(text_message)
		return render_template('main.html', name="main")

@app.route('/emu',methods=['POST'])
def api_led2():
	if request.headers['Content-Type'] == 'application/x-www-form-urlencoded':
		Message = request.form
		emulator = str(Message['emulator'])
		game = str(Message['game'])
		text_message = ((emulator, col.AQUA	), ("   ", (0, 0, 0)), (game, col.RED1))
		print(text_message)
		LED_Message(text_message)
		return render_template('index.html', name="index")


#curl -H "Content-type: application/json" --request POST http://192.168.1.220:5000/led --data '{"emulator":"MAME","game":"space"}'^

@app.route('/led',methods=['POST'])
def api_led():
	# print("in here")
	# print(request)
	# print("type :"  + request.headers['Content-type'])
	if request.headers['Content-Type'] == 'application/json':
		jsonMessage = request.get_json(silent=True)
		emulator = str(jsonMessage['emulator'])
		game = str(jsonMessage['game'])
		text_message = ((game, col.AQUA	), ("   ", (0, 0, 0)), (emulator, col.RED1))
		print(text_message)
		LED_Message(text_message)
		return "OK"	

if __name__== '__main__':
	app.run(host='0.0.0.0')


