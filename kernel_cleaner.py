#!/usr/bin/env python3

### This script removes all kernels except the current one. ###

import os
import sys

# Must run as root.
if not os.geteuid() == 0:
    sys.exit('Script must be run as root.')

# Check the running kernel.
kernel = os.popen('uname -r').read().strip()
last = (kernel.rfind("-"))
version = kernel[0:last]
#print (version)
input("Your current kernel is " + kernel.strip() + ". Press enter to continue...")
llista = []
path = os.path.dirname(os.path.abspath(__file__)) + "/list.txt"
#print (path)
os.system("dpkg-query -W -f='${binary:Package}\n' | egrep -i --color 'linux-image|linux-headers' > " + path)


file = open(path,'r')
for l in file:
    llista.append(l.strip())
#print (llista)
#print (kernel)
for k in llista:
    if version not in k:
        #print (k)
        os.system("apt-get purge " + k + " -y")
        os.system("apt-get autoremove -y")
os.system("rm " + path)