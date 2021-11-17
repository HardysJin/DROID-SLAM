FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
# 2: America; 151: vancouver
RUN set -ex && apt update -y && apt install vim -y && apt install sudo -y \
    && echo '2' | echo '151' | apt-get install software-properties-common -y \
    && apt install python3-pip -y \
    && pip3 install --upgrade pip \
    && apt install net-tools iputils-ping wget curl git unzip -y

# Dependencies for glvnd and X11.
RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    libxext6 \
    libx11-6 \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    freeglut3-dev \
  && rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

# DROID SLAM
RUN apt update && apt-get update \
    && pip install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html \
    && pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-1.9.1+cu111.html \
    && pip install open3d tensorboard scipy opencv-python tqdm matplotlib PyYAML gdown

RUN cd && git clone --recursive https://github.com/princeton-vl/DROID-SLAM.git

WORKDIR /root/DROID-SLAM

# DownloaD test data and checkpoint
RUN gdown https://drive.google.com/u/0/uc\?id\=1PpqVt1H4maBa_GbPJp4NwxRsd9jk-elh\&export\=download \
    && cd data && wget https://www.eth3d.net/data/slam/datasets/sfm_bench_mono.zip \
    && unzip sfm_bench_mono.zip \
    && rm sfm_bench_mono.zip 

# Compile
RUN python3 setup.py install
