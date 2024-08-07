#!/bin/bash
# set -x
# test case :
# in128 , out512-1024
# in512 , out1-256
# in1600-2048, out300-500
# in800-1024, out300-500

# llama2-7b
# model_name_dir=/nfs/models--meta-llama--Llama-2-7b-hf/snapshots/8cca527612d856d7d32bd94f8103728d614eb852
# model_name_dir=/models/llama2-70b-chat
# num_shard=1
# input_mean_arr=(128 512 1824 912)
# input_range_arr=(0 0 448 224)
# output_mean_arr=(768 256 400 400)
# output_range_arr=(512 256 200 200)
# dist_arr=("uniform" "capped_exponential" "uniform" "uniform")
# # data_type=bfloat16
# bs_arr=(16 32 64 128)

# llama2-70b
# model_name_dir=/models/llama2-70b-chat
# model_name_dir=/workspace/models--meta-llama--Llama-2-70b-chat-hf/snapshots/e1ce257bd76895e0864f3b4d6c7ed3c4cdec93e2
# num_shard=8
# input_mean_arr=(384 128 912)
# input_range_arr=(256 0 224)
# output_mean_arr=(384 912 128)
# output_range_arr=(256 224 0)
# dist_arr=("uniform" "uniform" "uniform")
# data_type=("bfloat16")
# bs_arr=(512)

# single case
# model_name_dir=/models/llama2-13b-chat/
# model_name_dir=/nfs/chaofanl/tgi/aicse.huggingface.model.references/Baichuan2/fine-tune/baichuan2-13b-chat
model_name_dir=/nfs/chaofanl/tgi/aicse.huggingface.model.references/Baichuan2/fine-tune/baichuan2-7b-chat

# model_name_dir=/checkpoint/hf/baichuan2-13b-chat/
num_shard=1
input_mean_arr=(1075)
input_range_arr=(0)
output_mean_arr=(200)
output_range_arr=(0)
bs_arr=(4)
dist_arr=("uniform")
data_type=("bfloat16")

# num_shard=1
# input_mean_arr=(128)
# input_range_arr=(0)
# output_mean_arr=(128)
# output_range_arr=(0)
# bs_arr=(8)
# dist_arr=("uniform")
# data_type=("bfloat16")


# export DBG_TRACE_FILENAME=debug.log
for dtype in "${data_type[@]}"
do 
    for bs in "${bs_arr[@]}"
    do
        idx=0
        for _ in "${input_mean_arr[@]}"
        do
            input_mean=${input_mean_arr[$idx]}
            input_range=${input_range_arr[$idx]}
            output_mean=${output_mean_arr[$idx]}
            output_range=${output_range_arr[$idx]}
            dist=${dist_arr[$idx]}
            echo "bs:$bs input_mean:$input_mean input_range:$input_range output_mean:$output_mean range:$output_range dist:$dist card_num $num_shard dtype $dtype"
            bash ./tgi_gaudi_variable_size $input_mean $output_mean $output_range $bs $dist $input_range $model_name_dir $num_shard $dtype 2>&1 | tee term_log_im${input_mean}_ir${input_range}_om${output_mean}_or${output_range}_bs${bs}_cn${num_shard}_dt${dtype}
            idx=$idx+1
        done
    done
done

