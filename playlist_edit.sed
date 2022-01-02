#
# Remove leading "File..=" of each line (necessary for .pls playlists)
s/^[Ff][Ii][Ll][Ee][0-9]*[0-9]*=//
#
# Add newline at the end of the file if missing, see https://unix.stackexchange.com/questions/31947/how-to-add-a-newline-to-the-end-of-a-file, try out with http://www.dradio.de/streaming/dkultur.m3u ! 
$a\
