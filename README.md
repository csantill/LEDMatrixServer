# LEDMatrixServer
Flask based server 



```
git clone https://github.com/csantill/LEDMatrixServer.git
cd LEDMatrixServer/
pip install -r requirements.txt
```

The server can be started by r
```
sudo python rpi-server.py
```

You can find the IP address of your server by 
```
sudo ifconfig



wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.220  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::b28c:bf04:f81e:e970  prefixlen 64  scopeid 0x20<link>
        ether b8:27:eb:fd:1b:99  txqueuelen 1000  (Ethernet)
        RX packets 515  bytes 50975 (49.7 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 291  bytes 46349 (45.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

use favorite browser and visit 

http://192.168.1.220:5000/ 



The web server is an interface to Henner Zeller RPI RGB LED matrix demo application

```
sudo apt-get update
sudo apt-get install git
sudo apt-get install libgraphicsmagick++-dev libwebp-dev
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev
git clone https://github.com/hzeller/rpi-rgb-led-matrix.git
cd ~/rpi-rgb-led-matrix/utils
make led-image-viewer
make video-viewer
cd ~/rpi-rgb-led-matrix/examples-api-use
make 
```
