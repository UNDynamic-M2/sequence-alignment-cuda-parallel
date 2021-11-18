FROM nvidia/cuda:11.4.2-devel-ubuntu20.04

RUN apt-get update && apt-get install -y --no-install-recommends \
curl \
ca-certificates \
python3 \
python3-distutils \
&& \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# RUN sudo apt-get install python3-distutils

# sudo apt-get install python3-apt

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
python3 get-pip.py && \
rm get-pip.py

COPY fetch_and_run.sh /usr/local/bin/

# Install pipenv
RUN pip install pipenv --upgrade
WORKDIR /home

COPY Pipfile Pipfile
RUN pipenv install
ENV LD_LIBRARY_PATH /usr/local/cuda-11.4/lib64:$LD_LIBRARY_PATH
ENV CUDA_HOME /usr/local/cuda-11.4
RUN chmod +x /usr/local/bin/fetch_and_run.sh

ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
