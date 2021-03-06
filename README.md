## NeuroPot (pip package)

NeuroPot is a library which provides automated processing of neuroradiological images, data cleaning and manipulation functionality, machine learning algorithms and transfer learning methods. **The preprocessing pipeline works for MPRAGE, but ones following ADNI protocol (MPR-R or MPRAGE REPEAT often DON'T follow the ADNI protocol, please check the orientations before use)**.

![Input image](assets/input.png?raw=true "Input image")
![Processed image](assets/processed.png?raw=true "Processed image")

### Docker

Build the docker image using:
```shell
docker build .
docker tag <image_id> neuropot:version1.0
```

Create a container:
```shell
docker create -it --name neuro1 neuropot:version1.0 bash
```

Start and attach to a container:
```shell
docker start -ai neuro1
```

This will drop you in the shell!
```shell
root@618cac06237d:/usr/src/preprocessor# 
root@618cac06237d:/usr/src/preprocessor# python
Python 3.6.7 (default, Oct 22 2018, 11:32:17) 
[GCC 8.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import neuropot.preprocessing as preproc
>>> 
```


### Quickstart

1. #### Setup FSL:

[Install FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation#Installing_FSL)
For MAC OSX, you can download the installer script [here](https://gist.github.com/abhinit/1cb51c695164497f068b608d3bad7565) 

It is important to follow the the [shell setup](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation/ShellSetup), one way to check whether the shell is not configured is that all fsl applications will appear with a 'fsl-5.0' prefix e.g. 'fsl-5.0-bet' instead of 'bet'.

'commands' package bug. FSL is slightly incompatible with python3. Commands package is depreciated in python3, but imported in a file in FSL (but not used!), so we can remove it:

```shell
sudo vim /usr/local/fsl/bin/aff2rigid 
```

Delete the following line:

```python
from commands import getoutput
```


3. #### Setup virtualenv

```python
#Install virtualenv in case not present
pip install virtualenv

#Setup a virtual environment
virtualenv neuro

#Activate the environment
source ./neuro/bin/activate

# You should see the prompt:
# (neuro)$

# To quit the virtualenv
# (neuro)$ deactivate
```

2. #### Install the neurpot package via pip:

```shell
(neuro)$ pip install neuropot
```

You should be good to go!

3. #### Now you can import and use the processing pipeline as follows:

```python
import neuropot.preprocessing as preproc
```
or
```python
from neuropot.preprocessing import *
```
You can try the samples given below.

Possible issue with permissions for executing ACPC detect - in case a 'Can't open ACPCAlignment.sh' error, check the permissions for the file and change it to executable:

```shell
sudo chmod +x /usr/local/bin/ACPCAlignment.sh
chown <username>:<username> /usr/local/bin/ACPCAlignment.sh
```

### Preprocessing pipeline:

This pipeline requires FSL: [Install FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation#Installing_FSL)

- N4 normalization
- ACPC correction
- Skull stripping
- GM Segmentation
- Normalization
- Smoothing

#### Preprocessing a single file:

```python
import os
import neuropot.preprocessing as preproc

path = os.getcwd()

# N4 normalization
# image_N4_path = preproc.n4_normalization(path+"/input.nii")
# print("Normalization done: ",image_N4_path)

# ACPC correction
image_N4_acpc_path = preproc.acpc_correction(path+"/input.nii")
print("ACPC correction done: ",image_N4_acpc_path)

# Skull stripping
image_N4_acpc_ss_path = preproc.skull_stripping(image_N4_acpc_path)
print("Skull stripping done: ",image_N4_acpc_ss_path)

# GM Segmentation
image_N4_acpc_ss_seg_path = preproc.gm_segmentation(image_N4_acpc_ss_path)
print("GM Segmentation done: ",image_N4_acpc_ss_seg_path)

# Normalization
image_N4_acpc_ss_seg_registered_path = preproc.normalization(image_N4_acpc_ss_seg_path)
print("Normalization done: ",image_N4_acpc_ss_seg_registered_path)

# Smoothing
image_N4_acpc_ss_seg_registered_smooth_path = preproc.smoothing(image_N4_acpc_ss_seg_registered_path)
print("Smoothing done: ",image_N4_acpc_ss_seg_registered_smooth_path)
```


#### Preprocessing multiple files:

```python
import os
import neuropot.preprocessing as preproc
from shutil import *

def preprocess(data_dir):
	processed = []
	total = len([file for file in os.listdir(data_dir) if file.endswith(".nii")])

	for idx,file in enumerate(os.listdir(data_dir)):
		if file.endswith(".nii"):
			input_file = os.path.join(data_dir, file)
			print("[%d/%d] Processing %s ... "%(idx+1,total,file),end="", flush=True),
			image_N4_acpc_path = preproc.acpc_correction(input_file)
			image_N4_acpc_ss_path = preproc.skull_stripping(image_N4_acpc_path)
			image_N4_acpc_ss_seg_path = preproc.gm_segmentation(image_N4_acpc_ss_path)
			image_N4_acpc_ss_seg_registered_path = preproc.normalization(image_N4_acpc_ss_seg_path)
			image_N4_acpc_ss_seg_registered_smooth_path = preproc.smoothing(image_N4_acpc_ss_seg_registered_path)
			processed.append(image_N4_acpc_ss_seg_registered_smooth_path)

			copyfile(image_N4_acpc_ss_seg_registered_smooth_path, os.path.join(data_dir,'processed_'+file+'.gz'))
			
			print("[DONE]")

	return processed

def main():
	data_dir = os.path.abspath("./mri")
	processed_files = preprocess(data_dir)
	print(processed_files)

main()
```
