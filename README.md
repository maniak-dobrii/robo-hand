## I designed this robot to show finger to my friend

![You will blame me for the size of that gif](/images/you_will_blame_me_for_the_size_of_that_gif.gif?raw=true)

Wi-Fi enabled robot that mimics human palm. Each finger is a set of rigid segments connected via revolute joints with rubber bands pulling them together. Each finger is flexed by servo, that is attached to it via fishing line (rubber bands extend it back). Servos are controlled by ESP8266 based board.

You'll need [SketchUp](https://www.sketchup.com/) to export frame models for printing, palm is available in both `.stl` and `.skp`. [Autodesk Eagle](https://www.autodesk.com/products/eagle/free-download) is required  to export mask for PCB. Both SketchUp and Eagle have free versions enough for export.

Currently Wi-Fi connectivity is not utilized, robot is controlled by two physical buttons, one for finger gesture, one for sign of the horns. 

### Palm
Palm itself is based on [design by Juan Gutierrez](https://www.thingiverse.com/thing:14986). In original design I didn't like thumb placement. If you only need the palm, I have it on [thingiverse](https://www.thingiverse.com/thing:2743350).

Except, of course, a 3D printer and filament, for palm you'll need:
 - **fishing line** to attach fingers to servos, could be found in a supermarket or fishing equipment store, anything will go,
 - **21 x m3x12 screws and nuts** (4 for each finger, thumb needs 3, 2 for binding palm base halfs)
 - **at least 14 1/4” rubber bands**, you might need more depending on their strength (but don't worry they are cheap and sold in big enough amounts). You can get those in orthodontic shops, they are 1/4” in diameter. In Russian they are called "эластики" or "ортодонтические резинки" or "резиновые тяги", they also have names for different hardnesses, I got "Медведь" 1/4, 4,5oz (strong), "Сова" 1/4, 2oz (weak one).

For more details see my [thingiverse](https://www.thingiverse.com/thing:2743350) remix.

### Frame
Frame is 3D printed as well, I used honeycomb pattern to make it robust, require less filament and look cool. In order to print it you'll need at least **134x170mm printing area**. In order to reduce printing time, bottom frame panel that has servos and PCB mounts is separated into two parts that are secured together by screw joints. All joints require m3 screws (different length, 8-16) and nuts, there are 21 total case/frame screw joints. At some point of designing frame I suddenly got deadlines, that lead to some fast decisions, so I can't tell which m3 screw lengths I used, just get yourself a kit of all sizes from 8 to 16mm.

### PCB and electronics
PCB here is just to avoid confusing wiring making construction more modular and clear. PCB allows more convenient connection between servos, ESP8266 board, power supply and power switch. It appeared that after all this years I've lost almost all my expertise in building PCBs, so don't learn from me on that =) Also, I've messed every thing possible in Eagle project, but it works.

Main PCB has a socket for Wemos D1 mini board, soldered DC jack and lots of pinheads to connect servos and buttons module. Buttons module hold tact switches that provide physical control.

 - ESP8266 board is some Wemos D1 mini clone I got from [aliexpress](https://ru.aliexpress.com/item/D1-mini-V2-Mini-NodeMcu-4M-bytes-Lua-WIFI-Internet-of-Things-development-board-based-ESP8266/32681374223.html?spm=a2g0s.9042311.0.0.aJtkSh), it has usb port and you can program it via Arduino IDE.
 - Power brick was excavated from my pile of "stuff to use somewhere", 5V 1A, that still works for 5x250ma servos peak draw and around 250ma peak ESP8266 draw (didn't test with wi-fi yet).
 - Power switch was the one that looked the best, mine was MRS-102A-C3, top frame panel has mounting hole for it.
 - Power jack is DS-201.
 - All servos are SG90. [SG90 SketchUp model](https://3dwarehouse.sketchup.com/model/b4d110b53afe39d821cd77f5063eab61/Servo-Tower-Pro-Micro-SG-90-with-horns) and was initially created by [James W.](https://3dwarehouse.sketchup.com/user/0712161666807539621944321/James-W?nav=models) and then updated by me according to real servos measurements.
 - Tact switches on buttons PCB are both 0350HIM-180G-G.


### Links to some parts
The way I approach such projects is that I often take breaks, really long breaks enough, for example, for my 3D printer to get covered with dust. So I tend to write everything down and I won't have to do research again. This time I was even not that lazy to keep a repo live. Here are parts I used, hope links won't be dead next time I look:
- Good quality cool black hex m3 screws and nuts set with a case, more enough to build this project: https://aliexpress.com/item/280Pcs-Set-M3-Cap-Head-Hex-Socket-Bolt-Screw-Nut-Metric-Machine-Fastener-Assortment-Set/32802252084.html
- Single size hex m3 screws, if you think you'll need more: https://www.aliexpress.com/item/New-24pcs-Lot-M3-Fully-Threaded-Black-Hex-Socket-Cap-Head-Screw-Bolt-Fastener-Set/32783442556.html
- m3 nuts, in case you want to stock up: https://www.aliexpress.com/item/100pcs-Metric-Thread-M3-M4-M5-M6-Black-Carbon-Steel-Hex-Nut-Hexagonal-Nut/32806225058.html
- Wemos D1 mini clone (ESP8266 board with usb): https://www.aliexpress.com/item/1PCS-D1-mini-Mini-NodeMcu-4M-bytes-Lua-WIFI-Internet-of-Things-development-board-based-ESP8266/32681374223.html
- SG90 servos - 10 pack: https://www.aliexpress.com/item/10PCS-9G-SG90-towerpro-micro-servo-motor-RC-Robot-Helicopter-Airplane-control/32326627136.html

All the other stuff I got from my local suppliers.
