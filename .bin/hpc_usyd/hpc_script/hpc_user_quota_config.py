##################################
'''
# Written by Shaoli Huang
# Date: 26 April 2018

# Modified by Jing Zhang
# Date: 17 Dec. 2018
#   [1]. add quota monitor @Dec. 12
#   [2]. add waiting time stats & hpc exec_vnode info @Dec.13
#   [3]. update the user_gpu_quota @Dec.13
#   [4]. update the warning criterion @Dec.16
#   [5]. update the hpc node information and warning criterion @Dec.17
#   [6]. update the user_gpu_quota @Feb. 1

# Modified by Hao Guan 
# Date: 3 Jul. 2019
# [1]. update user_gpu_quota
..............................................
The NEW rules: 
[1]. Everyone can only submit one job up to 1 v100 card at the INTERACTIVE mode. At the begining, we do not limit the duration. In the future, the maximum duration may be adjusted.

[2]. All other jobs within your gpu quota can only be submitted at the PBS mode. Please DO NOT submit an idle job at PBS mode to occupy gpus so that you can use them like the INTERACTIVE mode. Each jobs' usage statistics will be recorded by the hpc managers.

[3]. You can use the provided script to monitor the hpc usage and submit your jobs properly and efficiently. In the latest version, new features like waiting time statistics and hpc node information of the runing jobs are included. You can find it on the google drive (https://drive.google.com/drive/folders/1JMcoVEthiulMTUs7PbXkq9odRXI9jeYq?usp=sharing). We hope it will be helpful. 

[4]. Please keep in mind that the number of gpus you have used should not exceed your quota.  If you use more gpus than your quota, your userID will be highlighted in yellow. Everyone who uses the aforementioned script can monitor the hpc usage. To encourage all of us to take full use of the hpc gpus, we keep everyone's userID as normal color as long as there are no gpu jobs in the waiting list. Nevertheless, we strongly recommend that the extra training jobs beyond your quota should better be running during night, e.g, 10:00 pm ~10:00 am, when there are idle gpus.

[5]. For those whose task is complex, you can send a request with sound reasons to Prof. Tao for a temporary additional quota. If it has been approved, you shoud update the information in the google sheet(https://docs.google.com/spreadsheets/d/1mzexj9_ZY8SBxnf1yapuhBX0lIA9Ai31ChFsk_RFw5o/edit?usp=sharing). 

'''
#################################

DEBUG = False
MEM_PER_NODE = 187
CPU_PER_NODE = 36
GPU_PER_NODE = 4

user_gpu_quota = {
                    "cwan6915"	:  {"quota": 	6	if not DEBUG else 0, "quota_interactive":   1, "name":	"chaoyue wang"	},
                    "bayu0826"	:  {"quota": 	8	if not DEBUG else 0, "quota_interactive":   8, "name":	"baosheng yu"	}, #19.12.01
                    "jzha7896"	:  {"quota": 	8	if not DEBUG else 0, "quota_interactive":   1, "name":	"jing zhang"	},
                    "jwan5538"	:  {"quota": 	6	if not DEBUG else 0, "quota_interactive":   1, "name":	"jingya wang"	},
                    "shua0776"	:  {"quota": 	8	if not DEBUG else 0, "quota_interactive":   1, "name":	"shaoli huang"	},
                    "zche4307"	:  {"quota": 	8	if not DEBUG else 0, "quota_interactive":   8, "name": 	"zhe chen"	}, #19.12.01
                    
                    "szha2609"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name": 	"sen zhang"	}, 
                    "ycao8647"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"yu cao"	},
                    "mdon0736"	:  {"quota": 	3	if not DEBUG else 0, "quota_interactive":   1, "name":	"minjing dong"	},
                    "jguo6649"	:  {"quota": 	3	if not DEBUG else 0, "quota_interactive":   1, "name":	"jiaxian guo"	},
                    "zfen2406"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"zeyu feng"	},
                    "dguo8417"	:  {"quota": 	8	if not DEBUG else 0, "quota_interactive":   1, "name":	"dalu guo"	}, #19.12.01
                    "sima7436"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"sihan ma"	},
                    "fehe7727"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"fengxiang he"	},
                    "chli4934"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   2, "name":	"chang li"	},
                    "zche3175"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"zhuo chen"	},
                    "ldin3097"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"liang ding"	},
                    "tguo"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"tianyu guo"	},
                    "jqiu3225"	:  {"quota": 	6	if not DEBUG else 0, "quota_interactive":   1, "name":	"jiayan qiu"	}, #19.11.22
                    "zhtu3055"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"zhuozhuo tu"	},
                    "jwan4172"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"jue wang"	},
                    "hgua8781"	:  {"quota": 	3	if not DEBUG else 0, "quota_interactive":   1, "name":	"hao guan"	},
                    "xzha0505"	:  {"quota": 	3	if not DEBUG else 0, "quota_interactive":   1, "name":	"xikun zhang"	},
                    "syan9630"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"shuo yang"	},
                    "sguo2908"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"song guo"	},
                    "pzha7918"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"pengfei zhang"	},
                    "lzha0029"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"lianbo zhang"	},
                    "yzha0535"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"youjian zhang"	},
                    "szha4333"	:  {"quota": 	6	if not DEBUG else 0, "quota_interactive":   1, "name":	"shanshan zhao"	}, #19.12.01
                    "anli9659"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"ang li"	}, #20.02.01
                    "hahe7688"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"haoyu he"	},
                    "jwen0609"	:  {"quota": 	3	if not DEBUG else 0, "quota_interactive":   2, "name":	"jianfeng weng"	}, #20.02.20; interactive@19.11.15
                    "ycao5602"	:  {"quota": 	3	if not DEBUG else 0, "quota_interactive":   1, "name":	"yutong cao"	},
                    "tqia7904"	:  {"quota": 	2	if not DEBUG else 0, "quota_interactive":   1, "name":	"tingting qiao"	}, #19.11.15
                    "qzha2506"	:  {"quota": 	6	if not DEBUG else 0, "quota_interactive":   1, "name":	"qiming zhang"	}, #19.11.23
                    "jili8515"	:  {"quota": 	5	if not DEBUG else 0, "quota_interactive":   1, "name":	"jizhizi li"	}, #19.11.15
                    "bema0908"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"benteng ma"	},
                    "hzha0878"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"haimei zhao"	}, #19.11.15
                    "xzhu7491"	:  {"quota": 	3	if not DEBUG else 0, "quota_interactive":   1, "name":	"xinqi zhu"	},
                    "jgou2995"	:  {"quota": 	2	if not DEBUG else 0, "quota_interactive":   1, "name":	"jianping gou"	},
                    "qzhe6525"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"qi zheng"	},
                    "yzha9133"	:  {"quota": 	2	if not DEBUG else 0, "quota_interactive":   1, "name":	"yibing zhan"	},
                    "ssha4497"	:  {"quota": 	2	if not DEBUG else 0, "quota_interactive":   1, "name":	"sanjeev sharma"},
                    "zwan4121"	:  {"quota": 	4	if not DEBUG else 0, "quota_interactive":   1, "name":	"zhen wang"},

                    #"userId":     {"quota": 0 if not DEBUG else 0, "name": "userName"}, 
                }

HPC_NODE_INFO_ALLOC_DT = ['hpc223', 'hpc224', 'hpc225', 'hpc226', 'hpc227', 'hpc228', 'hpc229', 'hpc230', 'hpc231', 'hpc232', 
                          'hpc233', 'hpc234', 'hpc235', 'hpc236', 'hpc237', 'hpc238', 'hpc239', 'hpc246', 'hpc247', 'hpc248']
HPC_NODE_INFO_ALLOC_DT_NUM = len(HPC_NODE_INFO_ALLOC_DT)
HPC_GPUS_MAXIMUM = HPC_NODE_INFO_ALLOC_DT_NUM * GPU_PER_NODE

nonPBS_Maximum = 1