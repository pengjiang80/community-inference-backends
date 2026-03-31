# Base image containing the vLLM inference environment, requiring ARM(AArch64) CPU + Ascend NPU.
FROM quay.io/ascend/vllm-ascend:v0.11.0
#FROM quay.io/ascend/vllm-ascend:v0.11.0-a3
#FROM quay.io/ascend/vllm-ascend:v0.11.0-310p
# Base image containing the LMDeploy inference environment, requiring ARM(AArch64) CPU + Ascend NPU.
# FROM crpi-4crprmm5baj1v8iv.cn-hangzhou.personal.cr.aliyuncs.com/lmdeploy_dlinfer/ascend:mineru-a2

# Install libgl for opencv support & Noto fonts for Chinese characters
RUN apt-get update && \
    apt-get install -y \
        fonts-noto-core \
        fonts-noto-cjk \
        fontconfig \
        libgl1 \
        libglib2.0-0 && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install mineru latest
RUN python3 -m pip install -U pip && \
    python3 -m pip install 'mineru[core]>=3.0.0' \
                            numpy==1.26.4 \
                            opencv-python==4.11.0.86 && \
    python3 -m pip cache purge

# Download models and update the configuration file
RUN TORCH_DEVICE_BACKEND_AUTOLOAD=0 /bin/bash -c "mineru-models-download -s huggingface -m all"

# Set the entry point to activate the virtual environment and run the command line tool
ENTRYPOINT ["/bin/bash", "-c", "export MINERU_MODEL_SOURCE=local && exec \"$@\"", "--"]
