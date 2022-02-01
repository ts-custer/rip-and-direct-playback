# rip-and-direct-playback

A simple Bash script to record internet radio (aka "stream ripping") and playback the ripped audio file immediately. 

The names of the ripped audio files contain a timestamp and the radio station name, e.g. `2021-12-09_16-15-00 New Classical FM.mp3`. The audio files will be stored in a new created subfolder "recordings". So after you have stopped **rip-and-direct-playback** you can listen to them again (or delete them of course)!

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
$ ./rip_and_direct_playback.sh internet_radios.txt
```

**rip-and-direct-playback** will present you the following options:

```
s) Print stations
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

Enter number of the station to record and play (1)..
``` 
Just press Enter to record and listen the first radio station ("Radio Caroline" in our example).

You will see:

```
***** 1) Radio Caroline MP3 *****

Finding the real stream address:
http://sc8.radiocaroline.net:8040/; -> http://sc8.radiocaroline.net:8040/;
Starting recording.. OK
Writing file ./recordings/2021-12-10_12-07-17 Radio Caroline MP3.mp3
Starting playback.. OK


Enter number of the station to record and play (2)..
```
Note that the record file "2021-12-10_12-07-17 Radio Caroline MP3.mp3" is stored in the new created subfolder "recordings".

Press Enter again to record and listen the second station or enter the number of the station you would like to hear.

Enter "s" to see the station list again, "r" to restarting the playback (of the record file that is being written at the moment), "-" to record and listen to the previous station. Or "q" to quit.

## Known Problem

In case of large (e.g .flac) audio streams or slow internet connections it's possible that you don't hear anything. → Then enter "r" to restart the playback.
