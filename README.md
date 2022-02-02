# rip-and-direct-playback

A simple Bash script to record internet radio (aka "stream ripping") and playback the ripped audio file immediately. 

The names of the ripped audio files contain a timestamp and the radio station name, e.g. `2021-12-09_16-15-00 New Classical FM.mp3`. The audio files will be stored in a new created subfolder "recordings". So after you have stopped **rip-and-direct-playback** you can listen to them again (or delete them of course)!

![Screenshot5](https://user-images.githubusercontent.com/74509742/152213910-f935d177-a4b7-4868-889d-65e562b44e12.png)

## Prerequisites

The following need to be installed:
* tr
* sed
* wget
* screen
* vlc

## Usage

Edit `internet_radios.txt` with a text editor, enter the radio stations of your choice.

Make `rip_and_direct_playback.sh`, `stream_address_finder.sh` and `print_internet_radios.sh` executable: 
```
$ chmod +x rip_and_direct_playback.sh
$ chmod +x stream_address_finder.sh
$ chmod +x print_internet_radios.sh
```

Start **rip-and-direct-playback**:
```
./rip_and_direct_playback.sh internet_radios.txt
```

Then you will see:

```
RIP-AND-DIRECT-PLAYBACK  ***************************************** (C) TS CUSTER

s) Print stations
p) Pause playback
r) Restart playback
-) Select previous station
q) Quit

1) Radio Caroline MP3
2) NDR Kultur
3) New Classical FM
4) Czech Radio Vltava 224kbps
5) Deutschlandfunk 256kbps AAC
6) RBB Kultur MP3
7) Nativa FM AAC

Enter command key or station number (1)..
``` 
Just press "Enter" to record and listen the first radio station ("Radio Caroline" in our example).

You will see some additional lines:

```
SELECTED:  1) Radio Caroline MP3

Finding the real stream address:
http://sc8.radiocaroline.net:8040/ -> http://sc8.radiocaroline.net:8040/
Starting recording.. OK
Writing file ./recordings/2022-02-02_19-00-12 Radio Caroline MP3.mp3
Starting playback.. OK

Enter command key or station number (2)..
```
Note that the record file "2022-02-02_19-00-12 Radio Caroline MP3.mp3" is stored in the new created subfolder "recordings".

Press "Enter" again to record and listen the second station or enter the number of the station you would like to hear.

Or you can enter one of the command keys: s) Print stations, p) Pause playback, r) Restart playback, -) Select previous station, q) Quit

## Known Problem

In case of large (e.g .flac) audio streams or slow internet connections it's possible that you don't hear anything. → Then enter "r" to restart the playback.
