import urllib2
import requests
import time
import json
import sys
import getopt

monitoring_channel = None

def acquire_xos_monitoring_channel():
   admin_auth=("padmin@vicci.org", "letmein")  
   monitoring_channel = None
   ceilometer_service = None
   start_time = time.time()
   ceilometerservice_wait_start_time=start_time
   monitoringchannel_wait_start_time=start_time
   cur_attempts = 1
   print "Attempt %s" % cur_attempts
   while True:
      try:
         if (not ceilometer_service):
             url = "http://localhost:8888/api/core/services/"
             services = requests.get(url, auth=admin_auth).json()
             if not services:
                 print 'No services are found....weird....exiting'
                 return None
             else:
                 for service in services:
                     if 'ceilometer' in service['name']:
                         ceilometer_service = service
                         break
                 if (not ceilometer_service):
                     print 'Waiting for ceilometer_service object to be created, elapsed-time=%s' % (time.time()-ceilometerservice_wait_start_time)
                 else:
                     if ("OK" not in ceilometer_service['backend_status']):
                         cur_status = "other"
                         if "Unreachable" in ceilometer_service['backend_status']:
                             cur_status = "Unreachable"
                         elif "defer" in ceilometer_service['backend_status']:
                             cur_status = "Deferred"
                         print 'Waiting for ceilometer_service object to be ready, current_status:%s elapsed-time:%s' % (cur_status, time.time()-ceilometerservice_wait_start_time)
                         ceilometer_service = None
                     else:
                         print 'ceilometer_service is ready, elapsed-time:%s' % (time.time()-ceilometerservice_wait_start_time)
         else:
             print 'ceilometer_service is ready'
      except Exception, e:
         print 'Waiting for ceilometer_service object to be created, elapsed-time=%s' % (time.time()-ceilometerservice_wait_start_time)

      try:
         if (not monitoring_channel):
             url = "http://localhost:8888/api/tenant/monitoring/monitoringchannel/"
             monitoring_channels = requests.get(url, auth=admin_auth).json()
             if not monitoring_channels:
                 print 'Waiting for monitoring_channel object to be created, elapsed-time=%s' % (time.time()-monitoringchannel_wait_start_time)
             else:
                 monitoring_channel = monitoring_channels[0]
                 url = "http://localhost:8888/api/core/tenants/"+str(monitoring_channel['id'])
                 monitoring_channel = None
                 monitoring_channel = requests.get(url, auth=admin_auth).json()
                 if (not monitoring_channel) or ("OK" not in monitoring_channel['backend_status']):
                     cur_status = "other"
                     if "Unreachable" in monitoring_channel['backend_status']:
                         cur_status = "Unreachable"
                     elif "defer" in monitoring_channel['backend_status']:
                         cur_status = "Deferred"
                     print 'Waiting for Monitoring_channel to be ready, current_status:%s, elapsed-time=%s' % (cur_status, time.time()-monitoringchannel_wait_start_time)
                     monitoring_channel = None
                 else:
                     print 'Monitoring_channel is ready, elapsed-time:%s' % (time.time()-monitoringchannel_wait_start_time)
         else:
             print 'Monitoring_channel is ready'
      except Exception, e:
         print 'Exception....Waiting for monitoring_channel object to be created, elapsed-time=%s' % (time.time()-monitoringchannel_wait_start_time)

      if (not ceilometer_service) or (not monitoring_channel):
         #print "Sleeping for 60 seconds...."
         cur_attempts += 1
         if cur_attempts > 15:
             print "Maximum number of retrys reached....Exiting"
             return None
         time.sleep(60)
         print "Attempt %s" % cur_attempts
      else:
         print "Both ceilometer_service and monitoring_channel are ready"
         break

   #Wait until URL is completely UP
   while True:
       try:
           url = "http://localhost:8888/api/tenant/monitoring/monitoringchannel/"
           monitoring_channel = requests.get(url, auth=admin_auth).json()[0]
           if not monitoring_channel['ceilometer_url']:
               print 'Waiting for monitoring channel URL to be available, elapsed-time=%s' % (e.reason,time.time()-start_time)
               time.sleep(5)
               pass
           else:
               response = urllib2.urlopen(monitoring_channel['ceilometer_url'],timeout=5)
               break
       except urllib2.HTTPError, e:
           print 'HTTP error %s ...Means monitoring channel URL is reachable, elapsed-time=%s' % (e.reason,time.time()-start_time)
           return monitoring_channel
       except urllib2.URLError, e:
           print 'URL error...Waiting for monitoring channle URL %s is reachable, elapsed-time=%s' % (monitoring_channel['ceilometer_url'],time.time()-start_time)
           time.sleep(5)
           pass

def test_1():
   global monitoring_channel
   monitoring_channel = acquire_xos_monitoring_channel()
   assert monitoring_channel != None
   try:
      url = monitoring_channel['ceilometer_url']+"v2/meters"
      response = urllib2.urlopen(url,timeout=20)
      data = json.load(response)
      assert len(data) == 0, "Meters list is non empty for the first time"
      print 'CURL on ceilometer URL succeeded %s' % data
   except Exception, e:
      print 'CURL on ceilometer URL failed %s' % e
         
def test_2():
   global monitoring_channel
   if not monitoring_channel:
       monitoring_channel = acquire_xos_monitoring_channel()
       assert monitoring_channel != None
   try:
      url = monitoring_channel['ceilometer_url']+"v2/meters"
      response = urllib2.urlopen(url,timeout=20)
      data = json.load(response)
      assert len(data) != 0, "Meters list can not be empty after infra monitoring is enabled"
      print 'CURL on ceilometer URL succeeded Number of meters: %s' % str(len(data))
   except Exception, e:
      print 'CURL on ceilometer URL failed %s' % e

def usage():
    print 'monitoringservice_test.py --test=<num>'

def main(argv):
   try:
      opts, args = getopt.getopt(argv,"ht:",["help","test="])
   except getopt.GetoptError:
      usage()
      sys.exit(2)

   for opt, arg in opts:
      if opt in ("-h", "--help"):
          usage()
          sys.exit()
      elif opt in ("-t", "--test"):
          fq = "test_"+str(arg)
          globals()[fq]()

if __name__ == "__main__":
   main(sys.argv[1:])
