#FROM python:3.6-buster
FROM tageoforce/pytorchwithvision

USER root

WORKDIR /

RUN apt-get update && apt-get install -y apt-transport-https

# install dependencies from debian packages
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
    build-essential python3-pip \
    python3-setuptools \
    libglib2.0-0

RUN pip install --upgrade pip

# install dependencies from python packages
RUN pip --no-cache-dir install \
    RoboSat.pink && export PATH=$PATH:~/.local/bin

# download nvidia-driver
#RUN wget http://us.download.nvidia.com/XFree86/Linux-x86_64/430.40/NVIDIA-Linux-x86_64-430.40.run

# install nvidia-driver
#RUN NVIDIA-Linux-x86_64-430.40.run -a -q --ui=none