##################################
'''
# Written by Shaoli Huang
# Date: 26 April 2018

# Modified by Jing Zhang
# Date: 16 Dec. 2018
#   [1]. add quota monitor @Dec. 12
#   [2]. add waiting time stats & hpc exec_vnode info @Dec.13
#   [3]. update the user_gpu_quota @Dec.13
#   [5]. update the hpc node information and warning criterion @Dec.17

..............................................
The NEW rules: 
[1]. Everyone can only submit one job up to 1 v100 card at the INTERACTIVE mode. At the begining, we do not limit the duration. In the future, the maximum duration may be adjusted.

[2]. All other jobs within your gpu quota can only be submitted at the PBS mode. Please DO NOT submit an idle job at PBS mode to occupy gpus so that you can use them like the INTERACTIVE mode. Each jobs' usage statistics will be recorded by the hpc managers.

[3]. You can use the provided script to monitor the hpc usage and submit your jobs properly and efficiently. In the latest version, new features like waiting time statistics and hpc node information of the runing jobs are included. You can find it on the google drive (https://drive.google.com/drive/folders/1JMcoVEthiulMTUs7PbXkq9odRXI9jeYq?usp=sharing). We hope it will be helpful. 

[4]. Please keep in mind that the number of gpus you have used should not exceed your quota.  If you use more gpus than your quota, your userID will be highlighted in yellow. Everyone who uses the aforementioned script can monitor the hpc usage. To encourage all of us to take full use of the hpc gpus, we keep everyone's userID as normal color as long as there are no gpu jobs in the waiting list. Nevertheless, we strongly recommend that the extra training jobs beyond your quota should better be running during night, e.g, 10:00 pm ~10:00 am, when there are idle gpus.

[5]. For those whose task is complex, you can send a request with sound reasons to Prof. Tao for a temporary additional quota. If it has been approved, you shoud update the information in the google sheet(https://docs.google.com/spreadsheets/d/1mzexj9_ZY8SBxnf1yapuhBX0lIA9Ai31ChFsk_RFw5o/edit?usp=sharing). 

'''
#################################



import subprocess
import numpy as np
import re

import time
import json
import os

import pdb

from hpc_user_quota_config import *
                  
def parse_free_memory(output):
    patc = re.compile(r"Used\s+:\s+(\d+)\s+MiB")
    mo = patc.search(output)
    return int(mo.group(1))

def get_free_ngpu(host,ngpus=4):
    avail = np.zeros(ngpus)
    for i in range(ngpus):
        ncmd = "ssh {} nvidia-smi -q -d MEMORY -i {}"
        cmd = ncmd.format(host,str(i))
        try:
            output = subprocess.check_output(cmd,shell=True,
                                stderr=subprocess.STDOUT).decode("utf-8")
        except subprocess.CalledProcessError as e:
            #print("{} no response".format(host))
            avail[i] = 0
        else:
            avail[i] = parse_free_memory(output)
    return np.sum(avail == 0)


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING_QUOTA = '\033[93m' #yellow
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    WARNING_QUOTA_NONPBS = '\033[91m' #red
    WARNING_NONPBS = '\033[95m' #pink

total_cpus = 20*CPU_PER_NODE
total_gpus = 20*GPU_PER_NODE
total_mem = 20*MEM_PER_NODE

keywords = ['Job Id','Job_Owner','job_state','nchunks','ncpus','ngpus','mem','hosts', 'Job_Name', 'qtime', 'stime']
dicts = {}
hpc_usage = {}

for kw in keywords:
    if kw != "Job_Name":
        dicts[kw] = []
    else:
        dicts["nonPBS"] = []
        
output = subprocess.check_output("qstat -f alloc-dt",shell=True)

lines = output.splitlines()
lines = [str(lines[i])[2:-1] for i in range(len(lines))]
for l in range(len(lines)):
    line = lines[l]
    if 'Job_Owner' in line:
        dicts['Job_Owner'].append(line[16:][0:8])
        continue
    if 'Job Id' in line:
        dicts['Job Id'].append(line[8:][0:6])
        continue
    if 'job_state' in line:
        dicts['job_state'].append(line[16:])
        continue

    if 'Resource_List.nchunks' in line:
        dicts['nchunks'].append(int(line.split('=')[1]))
        continue

    if 'Resource_List.ncpus' in line:
        dicts['ncpus'].append(int(line.split('=')[1]))
        continue

    if 'Resource_List.ngpus' in line:
        dicts['ngpus'].append(int(line.split('=')[1]))
        continue

    if 'Resource_List.mem' in line:
        dicts['mem'].append(int(line.split('=')[1][:-2]))
        continue
    if 'exec_vnode' in line and 'estimate' not in line:
        if line[-1] != ')':
            line = line+lines[l+1].strip()
        line = line.split(' ')[-1]
        cmds = line.split('+')
        hoststr = ''
        for tstr in cmds:
            tstr = tstr[1:][:-1].split(':')
            hoststr += tstr[0]+' '
            if tstr[0] not in hpc_usage:
                hpc_usage[tstr[0]] = {'ngpus':0,'mem':0,'ncpus':0}

            for el in tstr[1:]:
                arr = el.split('=')
                keyn = arr[0]
                val = arr[1]
                if keyn == 'mem':
                    val = int(val[:-2])/1024/1024
                else:
                    val = int(val)
                hpc_usage[tstr[0]][keyn] += val
        dicts['hosts'].append(hoststr)
    
    if 'Job_Name' in line:
        dicts['nonPBS'].append(1 if "STDIN" in line else 0)
        continue
    
    if 'qtime' in line:
        dicts['qtime'].append(int(line.split('=')[1][9:11]) * 24 * 60 + int(line.split('=')[1][12:14]) * 60 + int(line.split('=')[1][15:17])) #minute
        continue
        
    if 'stime' in line:
        dicts['stime'].append(int(line.split('=')[1][9:11]) * 24 * 60 + int(line.split('=')[1][12:14]) * 60 + int(line.split('=')[1][15:17])) #minute
        continue

def get_usage(IS_SAVING_DATA = True):

    isR = np.array(dicts['job_state']) == 'R'
    isQ_idx = np.where(~isR)[0]
    for k in isQ_idx:
        dicts['stime'].insert(k, 0)
        dicts['hosts'].insert(k, '')
        
    usage = {}
    wait_str = ''
    idx = 0
    has_gpu_waiting_jobs = False
    waiting_gpus_sum = 0
    for user in dicts['Job_Owner']:
        if isR[idx]:
            if user not in usage:
                usage[user] = {}
                usage[user]['mem'] = dicts['mem'][idx]
                usage[user]['ngpus'] = dicts['ngpus'][idx]
                usage[user]['ncpus'] = dicts['ncpus'][idx]
                usage[user]['nonPBS'] = dicts['nonPBS'][idx] * dicts['ngpus'][idx]
                usage[user]['waittime'] = [dicts['stime'][idx] - dicts['qtime'][idx], dicts['ngpus'][idx]]
                #usage[user]['hosts'] = ''
                usage[user]['hosts'] = dicts['hosts'][idx] if idx < len(dicts['hosts']) else '' 
            else:
                usage[user]['mem'] += dicts['mem'][idx]
                usage[user]['ngpus'] += dicts['ngpus'][idx]
                usage[user]['ncpus'] += dicts['ncpus'][idx]
                usage[user]['nonPBS'] += dicts['nonPBS'][idx] * dicts['ngpus'][idx]
                usage[user]['waittime']+= [dicts['stime'][idx] - dicts['qtime'][idx], dicts['ngpus'][idx]]
                usage[user]['hosts'] += dicts['hosts'][idx] if idx < len(dicts['hosts']) else ''
        else:
            user_name = user_gpu_quota[user]["name"] if user in user_gpu_quota else 'unknown'
            wait_str += '    {}({}) '.format(user, user_name).ljust(29)
            wait_str += '| mem:{}gb ngpus:{} ncpus:{} \n'.format(dicts['mem'][idx],dicts['ngpus'][idx],dicts['ncpus'][idx])
            if dicts['ngpus'][idx] > 0:
                has_gpu_waiting_jobs = True
                waiting_gpus_sum += dicts['ngpus'][idx]

        idx += 1


    print('\n		' + bcolors.FAIL + 'HPC usage'+ bcolors.ENDC+'                          ')

    print('    {} nodes has been assigned \n'.format(len(hpc_usage.keys())))
    hpc_user_name = [key for key in hpc_usage]
    idx = np.argsort(-np.array([hpc_usage[k]["ngpus"] for k in hpc_usage]))
    hpc_host_usage_status = np.zeros(HPC_NODE_INFO_ALLOC_DT_NUM, np.bool)
    #for key,value in hpc_usage.items():
    for user_idx in range(len(hpc_usage)):
        key = hpc_user_name[idx[user_idx]]
        value = hpc_usage[key]

        mem = hpc_usage[key]['mem']
        ngpus = hpc_usage[key]['ngpus']
        ncpus = hpc_usage[key]['ncpus']
        freegpus = GPU_PER_NODE - ngpus
        
        pstr = '    {} | mem:{}gb ngpus:{} ncpus:{} idle_gpus:{} '.format(key,mem,ngpus,ncpus,freegpus)
        if mem < MEM_PER_NODE and ngpus < GPU_PER_NODE and ncpus < CPU_PER_NODE:
            pstr = bcolors.OKGREEN + pstr+ bcolors.ENDC
            
        if key in HPC_NODE_INFO_ALLOC_DT:
            print(pstr)
        
        if key in HPC_NODE_INFO_ALLOC_DT:
            hpc_host_usage_status[HPC_NODE_INFO_ALLOC_DT.index(key)] = True

    #pdb.set_trace()
    for idx in range(HPC_NODE_INFO_ALLOC_DT_NUM):
        if not hpc_host_usage_status[idx]:
            pstr = '    {} | mem:{}gb ngpus:{} ncpus:{} idle_gpus:{} '.format(HPC_NODE_INFO_ALLOC_DT[idx], 0, 0, 0, GPU_PER_NODE)
            pstr = bcolors.OKGREEN + pstr+ bcolors.ENDC
            print(pstr)

    print('    ----------------------------------------------------')
    print('		' + bcolors.FAIL + 'User usage'+ bcolors.ENDC+'                          ')

    avai_gpus = get_avai_gpus()
    avai_cpus = get_avai_cpus()
    avai_mem = get_avai_mem()
    print('    There are {} gpus avaialbe! '.format(avai_gpus))
    print('    There are {} cpus avaialbe! '.format(avai_cpus))
    print('    There are {}gb mem avaialbe! \n'.format(avai_mem))

    max_gpus = 0
    for key,value in usage.items():
        if value['ngpus'] > max_gpus:
            max_gpus = value['ngpus']


    tmpstr = ''
    hpc_user_name = [key for key in usage]
    usage_gpus_sum = np.sum(np.array([usage[k]["ngpus"] for k in usage]))
    idx = np.argsort(-np.array([usage[k]["ngpus"] for k in usage]))
    #for key,value in usage.items():
    for user_idx in range(len(usage)):
        key = hpc_user_name[idx[user_idx]]
        value = usage[key]
        
        user_gpu_quota_maximum = user_gpu_quota[key]["quota"] if key in user_gpu_quota else 0
        user_gpu_quota_interactive_maximum = user_gpu_quota[key]["quota_interactive"] if key in user_gpu_quota else 1
        usage[key]["quota"] = user_gpu_quota[key]["quota"] if key in user_gpu_quota else 0
        user_name = user_gpu_quota[key]["name"] if key in user_gpu_quota else 'unknown'
        
        pstr = '{}({})'.format(key, user_name).ljust(25)
        pstr = pstr + '| mem:{}gb ngpus:{} ncpus:{} hosts:[{}] '.format(value['mem'],value['ngpus'],value['ncpus'],value['hosts'])
        #if max_gpus == value[1]:
        if value['ngpus'] > user_gpu_quota_maximum and value["nonPBS"] <= user_gpu_quota_interactive_maximum and (usage_gpus_sum + waiting_gpus_sum > HPC_GPUS_MAXIMUM):
            print(bcolors.WARNING_QUOTA +'--> '+ pstr + bcolors.ENDC)
        elif value['ngpus'] > user_gpu_quota_maximum and value["nonPBS"] > user_gpu_quota_interactive_maximum and (usage_gpus_sum + waiting_gpus_sum > HPC_GPUS_MAXIMUM):
            print(bcolors.WARNING_QUOTA_NONPBS +'--> '+ pstr + bcolors.ENDC)
        elif value['ngpus'] <= user_gpu_quota_maximum and (value["nonPBS"] > user_gpu_quota_interactive_maximum) and (usage_gpus_sum + waiting_gpus_sum > HPC_GPUS_MAXIMUM):
            print(bcolors.WARNING_NONPBS +'--> '+ pstr + bcolors.ENDC)
        else:
            print('    '+pstr)


    print('    ----------------------------------------------------')
    print('		' + bcolors.FAIL + 'Waiting List'+ bcolors.ENDC+'                          ')
    print(wait_str)
    
    #calculate the wating time
    waittime = np.zeros((5,5), np.float) #whole, 1gpu, 2gpus, 3gpus, 4gpus; wait_time, gpu_count, min, max, med
    waittime[:, 2] = 1e10
    waittime_list = [[], [], [], [], []] #whole, 1gpu, 2gpus, 3gpus, 4gpus
    for user_idx in range(len(usage)):
        key = hpc_user_name[idx[user_idx]]
        value = usage[key]
        user_waittime = np.array(value["waittime"]).reshape((-1,2))
        waittime[0,0] += user_waittime[:, 0].sum()
        waittime[0,1] += len(user_waittime[:, 0])
        waittime[0,2] = min(waittime[0, 2], min(user_waittime[:, 0]))
        waittime[0,3] = max(waittime[0,3], max(user_waittime[:, 0]))
        waittime_list[0] += user_waittime[:, 0].tolist()
        
        for k in range(1, 5):
            waittime_flag = np.where(user_waittime[:, 1] == k)[0]
            #print("{}: {}".format(k, waittime_flag))
            if len(waittime_flag) > 0:
                waittime[k, 0] += user_waittime[waittime_flag, 0].sum()
                waittime[k, 1] += len(waittime_flag)
                waittime[k, 2] = min(waittime[k, 2], min(user_waittime[waittime_flag, 0]))
                waittime[k, 3] = max(waittime[k, 3], max(user_waittime[waittime_flag, 0]))
                waittime_list[k] += user_waittime[waittime_flag, 0].tolist()
    for k in range(0, 5):
        waittime[k, 4] = np.median(np.array(waittime_list[k])) if len(waittime_list[k]) > 0 else 0 
        waittime[k, 2] = 0 if len(waittime_list[k]) == 0 else waittime[k, 2] 
        
    print('    ----------------------------------------------------')
    print('		' + bcolors.FAIL + 'Waiting Time Stats'+ bcolors.ENDC+'                          ')
    print("    %3d   gpu   jobs: Ave.: %5.1fmin; Med.: %5.1fmin (%5.1fmin ~ %5.1fmin)" % (int(waittime[0,1]), (waittime[0,0] / (waittime[0,1] + 1e-6) ), (waittime[0, 4]), (waittime[0, 2]), (waittime[0, 3]) ))
    for k in range(1, 5):
        print("    %3d  %1d-gpu  jobs: Ave.: %5.1fmin; Med.: %5.1fmin (%5.1fmin ~ %5.1fmin)" % (int(waittime[k, 1]), k, (waittime[k, 0] / (waittime[k, 1] + 1e-6) ) , (waittime[k, 4]), (waittime[k, 2]), (waittime[k, 3]) ))

    #save data
    if IS_SAVING_DATA:
        hour_freq = 6.0
        t = time.localtime(time.time())
        year = "%04d" % t[0]
        month = "%02d" % t[1]
        day = "%02d" % t[2]
        hour = "%02d" % int(t[3] / hour_freq)
        hpc_usage_stats = year + month + day + "_" + hour + "_hpc_usage_stats.json"
        hpc_usage_stats_dir = os.path.join("./hpc_usage_stats/", year + month)
        if not os.path.exists(hpc_usage_stats_dir):
            os.makedirs(hpc_usage_stats_dir)
        dat = {"usage": usage, "waittime": waittime.tolist(), "user_gpu_quota": user_gpu_quota, "waittime_list": waittime_list}
        json.dump(dat, open(os.path.join(hpc_usage_stats_dir, hpc_usage_stats), "w"))

def get_avai_mem():
    return (total_mem - sum(np.array(dicts['mem'])[np.array(dicts['job_state']) == 'R']))

def get_avai_gpus():
    return (total_gpus - sum(np.array(dicts['ngpus'])[np.array(dicts['job_state']) == 'R']))

def get_avai_cpus():
    return (total_cpus - sum(np.array(dicts['ncpus'])[np.array(dicts['job_state']) == 'R']))

get_usage()


