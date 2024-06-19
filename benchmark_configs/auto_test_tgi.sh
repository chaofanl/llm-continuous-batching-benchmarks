#!/bin/bash
# set -x

# test case :
# in128 , out512-1024
# in512 , out1-256
# in1600-2048, out300-500
# in800-1024, out300-500

# input_mean_arr=(128 512 1824 912)
# input_range_arr=(0 0 448 224)
# output_mean_arr=(768 256 400 400)
# output_range_arr=(512 256 200 200)

input_mean_arr=(1824 912)
input_range_arr=(448 224)
output_mean_arr=(400 400)
output_range_arr=(200 200)
bs_arr=(16 32 64 128)

dist_arr=("uniform" "capped_exponential" "uniform" "uniform")

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
        echo "bs:$bs input_mean:$input_mean input_range:$input_range output_mean:$output_mean range:$output_range dist:$dist"
        bash ./tgi_gaudi_variable_size $input_mean $output_mean $output_range $bs $dist $input_range 2>&1 | tee term_log_im${input_mean}_ir${input_range}_om${output_mean}_or${output_range}_bs${bs}
        # print_o=$(( output + range ))
        # print_r=$((range * 2))
        # mv ../bsoutput_new.txt ./bs_modeltime/i${input}_o${print_o}_range${print_r}_bs${bs}.txt
        idx=$idx+1
    done
done

