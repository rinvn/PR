#!/usr/bin/python
import json
import boto3
import time
import sys
import os

#define aws object 
cw  = boto3.client("cloudwatch")
dashboardName = "AutoUpdateBeanstalkDashboard-luan"

s3 = boto3.client('s3')
bucketName = "training-md-luan-bucket01"
Retain_Number = 3

autoscalinggroupname = "awseb-e-xpc3sz4isz-stack-AWSEBAutoScalingGroup-11T8119X49K0C"
asg = boto3.client('autoscaling',region_name='ap-northeast-1')
decriberasg = asg.describe_auto_scaling_groups(
    AutoScalingGroupNames = [autoscalinggroupname],
)


#Get list of instance-ids from autoscaling group 
instance_ids = []
for i in decriberasg ['AutoScalingGroups']:
 for k in i['Instances']:
  instance_ids.append(k['InstanceId'])
print 'Saved autoscaling instance-id into ListOfInstances\n'


#Write list of instance-ids into file and upload to s3
instance_ids_file = 'ListOfInstances_' + time.strftime("%Y%m%d%H%M%S")
with open(instance_ids_file, 'w') as f:
 for item in instance_ids :
  f.write(str(item) + '\n')
content = open(instance_ids_file, 'rb')
s3.put_object(
   Bucket = bucketName,
   Key = '%s/%s' %("List_Of_Instances",instance_ids_file),
   Body = content
)
print ('Uploaded ListOfInstances: ' + instance_ids_file + ' to s3 \n')



#Remove all local file which has format like ListOfInstances_* 
rmListOfInstancesCmd = '/bin/ls `pwd`/ListOfInstances_* | xargs rm -f > /dev/null 2>&1'
os.system(rmListOfInstancesCmd)
print ('Removed all local ListOfInstances files \n')


#Delete the oledest ListOfInstances file in s3 if total number of ListOfInstances file is more than Retain_Number
get_last_modified = lambda obj: int(obj['LastModified'].strftime('%s'))
objs = s3.list_objects_v2(Bucket=bucketName,Prefix = 'List_Of_Instances/ListOfInstances')['Contents']
sortedKeys = [obj['Key'] for obj in sorted(objs, key=get_last_modified)]
if (len(sortedKeys) > Retain_Number):
    deleteS3Key = sortedKeys.pop(0)
    response = s3.delete_object(Bucket=bucketName, Key=deleteS3Key)
print ('Deleted the oldest ListOfInstances' + ' with key : ' + deleteS3Key  + ' in S3 \n')

#Download all ListOfInstances to local
for i in range(len(sortedKeys)):
 lastSep = sortedKeys[i].rfind('/')
 file = sortedKeys[i][lastSep+1:]
 with open(file, 'wb') as data:
    s3.download_fileobj(bucketName, sortedKeys[i], data)
print ('Download all ListOfInstances from S3 to local \n')


#Create CombinedListOfInstances file to combine all instance-id from  ListOfInstances files
CombinedListOfInstances = 'CombinedListOfInstances_' + time.strftime("%Y%m%d%H%M%S")
combineInstanceListsCmd = '/bin/cat ListOfInstances_* | sort | uniq > output'
os.system(combineInstanceListsCmd)
with open("output") as f:
    with open(CombinedListOfInstances, "w") as f1:
        for line in f:
            f1.write(line)
rmOutputCmd = '/bin/rm -f output > /dev/null 2>&1'
os.system(rmOutputCmd)
print ('Created ' + CombinedListOfInstances + '\n')


#Remove all local file which has format like ListOfInstances_* 
rmListOfInstancesCmd = '/bin/ls `pwd`/ListOfInstances_* | xargs rm -f > /dev/null 2>&1'
os.system(rmListOfInstancesCmd)


#Upload CombinedListOfInstances file to S3
content = open(CombinedListOfInstances, 'rb')
s3.put_object(
   Bucket = bucketName,
   Key = '%s/%s' %("Combined_List_Of_Instances",CombinedListOfInstances),
   Body = content
)
print ('Uploaded' + CombinedListOfInstances  + ' to S3 \n')


#Create dashboard and put_dashboard to cloudwatch
ListOfInstances = list()
ListOfInstances = [line.rstrip('\n') for line in open(CombinedListOfInstances)]



metric_types= {
    "DiskSpaceUtilization" : [ "System/Linux", "DiskSpaceUtilization", "MountPath", "/", "InstanceId", "Filesystem", "/dev/xvda1" ],
    "DiskWriteOps" : [ "AWS/EC2", "DiskWriteOps", "InstanceId" ],
    "MemoryUtilization" : [ "System/Linux", "MemoryUtilization", "InstanceId" ],
    "1MinLoadAverage" : [ "System/Linux", "1MinLoadAverage", "InstanceId" ],
    "5MinLoadAverage" : [ "System/Linux", "5MinLoadAverage", "InstanceId" ],
    "NetworkIn" : [ "AWS/EC2", "NetworkIn", "InstanceId" ],
    "NetworkOut" : [ "AWS/EC2", "NetworkOut", "InstanceId" ],
    "DiskReadOps" : [ "AWS/EC2", "DiskReadOps", "InstanceId" ],
    "CPUUtilization" : [ "AWS/EC2", "CPUUtilization", "InstanceId" ]

}

def build_widget(metric_type):
 metrics = list()
 metric = {}
 for i in range(len(ListOfInstances)):
  temp = list()
  temp.append((ListOfInstances[i]))
  metric = metric_types[metric_type] + temp
  #DiskSpaceUtilization has a diffirent definition-format with others, so we exchange last element with 4th-from-last element
  if (metric_type == "DiskSpaceUtilization"):
   metric[-1], metric[-3] = metric[-3], metric[-1]
   metric[-1], metric[-2] = metric[-2], metric[-1]
  metrics.append(metric)
 properties = {}
 properties["region"] = "ap-northeast-1"
 properties["metrics"] = metrics
 widget = {}
 widget["type"] = "metric"
 widget["properties"] = properties
 return widget

#Build dashboard and putDashBoard to Cloudwatch
widgets = list()
for key in metric_types.keys():
 widgets.append(build_widget(key))
dashboard = {}
dashboard["widgets"] = widgets
dashboard_json = json.dumps(dashboard)
cw.put_dashboard(DashboardName = dashboardName,
                 DashboardBody = dashboard_json)
print ('Updated dashboard name : ' + dashboardName + ' sucessfully \n')


#Delete the oledest CombinedListOfInstance files in s3 if total number of CombinedListOfInstances file is more than Retain_Number
objsCb = s3.list_objects_v2(Bucket=bucketName,Prefix = 'Combined_List_Of_Instances/CombinedListOfInstances')['Contents']
sortedKeysCb = [obj['Key'] for obj in sorted(objsCb, key=get_last_modified)]
if (len(sortedKeysCb) > 3):
    deleteS3Key = sortedKeysCb.pop(0)
    response = s3.delete_object(Bucket=bucketName, Key=deleteS3Key)
print('Deleted the oldest CombinedListOfInstance '+ ' with key: ' + deleteS3Key + '\n')

#Remove all local file which has format like CombinedListOfInstances_* 
rmCombinedListOfInstancesCmd = '/bin/ls `pwd`/CombinedListOfInstances_* | xargs rm -f > /dev/null 2>&1'
os.system(rmCombinedListOfInstancesCmd)
print('Remove all local file which has format like CombinedListOfInstances_* \n')
print('All done ! \n')
