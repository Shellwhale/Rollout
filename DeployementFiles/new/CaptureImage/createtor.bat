Y:\mktorrent-1.0-win-64bit-build1\mktorrent.exe -a http://tracker.pedagogique.lan -o win10a_edu.wim.torrent -p win10a_edu.wim -n win10a_edu.wim
aria2c /V -d . win10a_edu.wim.torrent --seed-ration=1.0
aria2c /V -d . win10a_edu.wim.torrent --seed-time=10