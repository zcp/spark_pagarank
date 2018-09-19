# randomURL.py
# Finds and displays a random webpage.
# FB - 201009127
import random
import urllib2

max_lines = 10000/5
def genURL():
    f = open("url_data", "a+");
    i = 0
    while(i < max_lines):
       ip0 = str(random.randint(0, 255))
       ip1 = str(random.randint(0, 255))
       ip2 = str(random.randint(0, 255))
       ip3 = str(random.randint(0, 255))
       url = 'http://' + ip0 + '.' + ip1 + '.'+ ip2 + '.'+ ip3
 
       ip0 = str(random.randint(0, 255))
       ip1 = str(random.randint(0, 255))
       ip2 = str(random.randint(0, 255))
       ip3 = str(random.randint(0, 255))      
       neighbour_url = 'http://' + ip0 + '.' + ip1 + '.'+ ip2 + '.'+ ip3

       f.write(url + "\t" + neighbour_url + "\n")
       i += 1
    f.close()


genURL()

