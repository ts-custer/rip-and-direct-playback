# rip-and-direct-playback

A simple Bash script to record internet radio (aka "stream ripping") and playback the ripped audio file immediately. 

The names of the ripped audio files contain a timestamp and the radio station name, e.g. `2021-12-09_16-15-00 New Classical FM.mp3`. The audio files will be stored in a new created subfolder "recordings". So after you have stopped **rip-and-direct-playback** you can listen to them again (or delete them of course)!

## Prerequisites

The following need to be installed:
* sed
* gawk
* wget
* vlc

## Usage

Open `internet_radios.csv` with MS Excel or Libre Office Calc and enter the internet radio stations you would like to listen and record:

![Screenshot](https://user-images.githubusercontent.com/74509742/145563746-276b50de-217e-442f-963d-062924ad98d9.png)

Make `rip_and_direct_playback.sh` and `stream_address_finder.sh` executable: 
```
$ chmod +x rip_and_direct_playback.sh
$ chmod +x stream_address_finder.sh
$ chmod +x print_csv.sh
```

Start **rip-and-direct-playback**:
```
$ ./rip_and_direct_playback.sh
```

**rip-and-direct-playback** will present you the following options:

```
s) Print stations
r) Restart playback
-) Select previous station
q) Quit

1) Radio Caroline
2) NDR Kultur
3) New Classical FM
4) Czech Radio Vltava 224kbps OGG
5) Deutschlandfunk 256kbps AAC
6) RBB Kultur
7) Nativa FM

Enter number of the station to record and play (1)..
``` 
Just press Enter to record and listen the first radio station ("Radio Caroline" in our example).

You will see:

```
***** 1) Radio Caroline *****

Finding the real stream address:
http://sc8.radiocaroline.net:8040/; -> http://sc8.radiocaroline.net:8040/;
Starting recording.. OK
Writing file ./recordings/2021-12-10_12-07-17 Radio Caroline.mp3
Starting playback.. OK

VLC media player 3.0.9.2 Vetinari (revision 3.0.9.2-0-gd4c1aefe4d)
[000055f8df350300] dummy interface: using the dummy interface module...

Enter number of the station to record and play (2)..
```
Note that the record file "2021-12-10_12-07-17 Radio Caroline.mp3" is stored in the new created subfolder "recordings".

Press Enter again to record and listen the second station or enter the number of the station you would like to hear.

Enter "s" to see the station list again, "r" to restarting the playback (of the record file that is being written at the moment), "-" to record and listen to the previous station. Or "q" to quit.

## Known Problems

In case of large (e.g .flac) audio streams or slow internet connections it's possible that you don't hear anything. → Then enter "r" to restart the playback.

VLC creates output on console (e.g. `[000012ab34..] dummy interface: using the dummy interface module...`) that could not be suppressed.


