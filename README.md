# rip-and-direct-playback

A simple Bash script to record internet radio (aka "stream ripping") and playback the ripped audio file immediately. 

The names of the ripped audio files contain a timestamp and the radio station name, e.g. `2021-12-09_16-15-00 New Classical FM.mp3`. The audio files will be stored in a new created subfolder `recordings`. So after you have stopped **rip-and-direct-playback** you can listen to them again (or delete them of course)!

## Prerequisites

The following need to be installed:
* wget
* sed
* vlc

## Usage

Open `internet_radios.csv` with MS Excel or Libre Office Calc and enter the internet radio stations you would like to listen and record:

Screenshot

Make `rip_and_direct_playback.sh` and `stream_address_finder.sh` executable: 
```
$ chmod +x rip_and_direct_playback.sh
$ chmod +x stream_address_finder.sh
```

Start **rip-and-direct-playback**:
```
$ ./rip_and_direct_playback.sh
```

**rip-and-direct-playback** will present you the following options:

```
s) Print stations
r) Restarting playback
q) Quit

1) Radio Caroline
2) NDR Kultur
3) New Classical FM
4) Czech Radio Vltava 224kbps OGG
5) Deutschlandfunk 256kbps AAC
6) Nativa FM

Enter number of the station to record and play (1)..
``` 
Just press Enter to record and listen the first radio station ("Radio Caroline" in our example).

You will see:

```
***** 1) Radio Caroline *****

Finding the real stream address:
http://sc8.radiocaroline.net:8040/; -> http://sc8.radiocaroline.net:8040/;
Starting recording.. OK
Waiting.. OK
Starting playback.. OK

VLC media player 3.0.9.2 Vetinari (revision 3.0.9.2-0-gd4c1aefe4d)
[000056304177c890] dummy interface: using the dummy interface module...

Enter number of the station to record and play (2)..
```
Then just press Enter again to record and listen the second station or enter the number of the station you would like to hear.

Enter "s" to see the station list again, "r" to restarting the playback (of the record file that is being written at the moment) or "q" to quit.

## Known Problems

In case of large (e.g .flac) audio streams or slow internet connections it's possible that you don't hear anything. → Then enter "r" to restart the playback.

VLC creates output on console (e.g. `[000012ab34..] dummy interface: using the dummy interface module...`) that could not be suppressed.


