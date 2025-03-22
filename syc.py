import datetime
import inspect
import os
import pytz
import subprocess
import sys

def main( args ):
    now = datetime.datetime.now( tz=pytz.timezone( 'US/Eastern' ) )
    # TODO: check if the file already exists
    # TODO: check if the time is within daylight hours
    #   I should be able to use the ephem package, but I can't seem to get the
    #   timezone conversion correctly
    #       import ephem
    #       sarnia = ephem.Observer()
    #       sarnia.pressure = 0
    #       sarnia.horizon = '-0:34'
    #       sarnia.lat, sarnia.long = '43.0', '-82.4'
    #       sarnia.date = '2018/05/23 17:00' # 17:00 is solar noon for the day
    #       print sarnia.next_rising( ephem.Sun() )
    #
        # TODO: delete the downloaded file if it's empty
        # TODO: delete the downloaded file if it's the same as the previously
        # downloaded file (the webcam stops updating at night)
    d = os.path.dirname( os.path.abspath( inspect.getfile( inspect.currentframe() ) ) )
    filename = "%04d-%02d-%02d-%02d.jpg" % (now.year, now.month, now.day, now.hour)
    p = subprocess.Popen( [ "wget",
                            "http://sarniayachtclub.ca/webcam/FI9900P_C4D6554097B7/snap/webcam_1.jpg",
                            "-O", os.path.join( d, filename ) ],
                          stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE )
    p.communicate()
    p.wait()

if __name__ == '__main__':
    sys.exit( main( sys.argv ) )
