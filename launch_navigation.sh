#!/bin/bash

#### CUSTOMIZE HERE #####

S3_BUCKET="deliverychallengevocstar-robomakerdeliverychallen-1f74s591cp5mg"
ROLE_ARN="arn:aws:iam::844865025170:role/delivery-challenge-simulation-role-us-east-1"
SUBNET='["subnet-6ef7fc23", "subnet-ab6219cd", "subnet-2bea641a", "subnet-b1d490ee", "subnet-306d2c11", "subnet-e1c0fdef"]' # example  '["subnet-1303f974", "subnet-939d74da", "subnet-d7063791"]'
SECURITY_GROUP='["sg-a4611da3"]' # example '["sg-012ffd67"]'

S3_BUNDLE_BASEPATH="aws-robomaker-sample-application-delivery-challenge"

PATH_TO_SIM_APP_WORKSPACE="simulation_ws"
PATH_TO_ROBOT_APP_WORKSPACE="robot_ws"

SIMULATION_APPNAME="deliverychallenge_sumulation_user1470647-mbuonastella-myseneca-ca"
SIM_APP_PACKAGE="delivery_challenge_simulation"
SIM_APP_LAUNCH_FILE="create_stage.launch"
SIM_APP_ENV="{\"TURTLEBOT3_MODEL\": \"burger\"}"

ROBOT_APPNAME="deliverychallenge_robot_user1470647-mbuonastella-myseneca-ca"
ROBOT_APP_PACKAGE="delivery_robot_sample"
ROBOT_APP_LAUNCH_FILE="navigation_simulation.launch"
ROBOT_APP_ENV="{}"

GAZEBO_VERSION=9 
ROS_VERSION=Melodic 
 
#### CUSTOMIZE HERE END #####

S3KEY_SIM_APP=$S3_BUNDLE_BASEPATH/$PATH_TO_SIM_APP_WORKSPACE/bundle/output.tar
S3KEY_ROBOT_APP=$S3_BUNDLE_BASEPATH/$PATH_TO_ROBOT_APP_WORKSPACE/bundle/output.tar

# Copy bundle to Amazon S3
aws s3 cp $PATH_TO_SIM_APP_WORKSPACE/bundle/output.tar s3://$S3_BUCKET/$S3KEY_SIM_APP
aws s3 cp $PATH_TO_ROBOT_APP_WORKSPACE/bundle/output.tar s3://$S3_BUCKET/$S3KEY_ROBOT_APP

# Reister simulation application
aws robomaker create-simulation-application \
--name $SIMULATION_APPNAME \
--sources "s3Bucket=$S3_BUCKET,s3Key=$S3KEY_SIM_APP,architecture=X86_64" \
--simulation-software-suite "name=Gazebo,version=$GAZEBO_VERSION" \
--robot-software-suite "name=ROS,version=$ROS_VERSION" \
--rendering-engine "name=OGRE,version=1.x"　

# Register robot application
aws robomaker create-robot-application \
--name $ROBOT_APPNAME \
--sources "s3Bucket=$S3_BUCKET,s3Key=$S3KEY_ROBOT_APP,architecture=X86_64" \
--robot-software-suite "name=ROS,version=$ROS_VERSION"　

# Query simulation app
sim_app=`aws robomaker list-simulation-applications | grep -o "arn:aws:robomaker:.*:simulation-application/${SIMULATION_APPNAME}.[^,\"]*"`

# Query robot app
robo_app=`aws robomaker list-robot-applications |  grep -o "arn:aws:robomaker:.*:robot-application/${ROBOT_APPNAME}.[^,\"]*"`

# Update
aws robomaker update-simulation-application \
--application $sim_app \
--sources "s3Bucket=$S3_BUCKET,s3Key=$S3KEY_SIM_APP,architecture=X86_64" \
--simulation-software-suite "name=Gazebo,version=$GAZEBO_VERSION" \
--robot-software-suite "name=ROS,version=$ROS_VERSION" \
--rendering-engine "name=OGRE,version=1.x"　

aws robomaker update-robot-application \
--application $robo_app \
--sources "s3Bucket=$S3_BUCKET,s3Key=$S3KEY_ROBOT_APP,architecture=X86_64" \
--robot-software-suite "name=ROS,version=$ROS_VERSION"　

# Launch
template='
    {   "iamRole":"%s", 
        "maxJobDurationInSeconds":1800, 
        "failureBehavior":"Fail", 
        "simulationApplications":[{"application":"%s","applicationVersion":"$LATEST",
            "launchConfig":{
              "packageName":"%s","launchFile":"%s",
              "environmentVariables": %s
            }}],
        "robotApplications":[{"application":"%s","applicationVersion":"$LATEST",
            "launchConfig":{
              "packageName":"%s","launchFile":"%s",
              "environmentVariables": %s,
              "streamUI": true
            }}], 
        "vpcConfig":{"subnets":%s,"securityGroups":%s,"assignPublicIp":true}}'

json_params=$(printf "$template" "$ROLE_ARN" "$sim_app" "$SIM_APP_PACKAGE" "$SIM_APP_LAUNCH_FILE" "$SIM_APP_ENV" "$robo_app" "$ROBOT_APP_PACKAGE" "$ROBOT_APP_LAUNCH_FILE" "$ROBOT_APP_ENV" "$SUBNET" "$SECURITY_GROUP")

aws robomaker create-simulation-job --cli-input-json "$json_params"

