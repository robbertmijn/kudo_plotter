#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 11 11:53:17 2020
https://medium.com/swlh/using-python-to-connect-to-stravas-api-and-analyse-your-activities-dummies-guide-5f49727aac86
@author: robbertmijn
"""

import requests
from pandas.io.json import json_normalize
import json
# import csv
# Get the tokens from file to connect to Strava
with open('strava_tokens.json') as json_file:
    strava_tokens = json.load(json_file)
# Loop through all activities
url = "https://www.strava.com/api/v3/activities"
access_token = strava_tokens['access_token']
page = 1

while 1:
    
    r = requests.get(url + '?access_token=' + access_token + '&per_page=200' + '&page=' + str(page))
    r = r.json()
    
    if (not r):
        break
    
    
    df = json_normalize(r)
    df.to_csv('strava_activities_all_fields_' + str(page) + '.csv')
    page += 1
