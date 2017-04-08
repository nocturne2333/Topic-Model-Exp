#!/bin/bash
# run an toy example for BTM

#dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd /speechlab/users/htl11/topic-model/btm/script/

K=100   # number of topics

alpha=`echo "scale=3;50/$K"|bc`
beta=0.001
niter=1000
save_step=20
has_b=0
fstop=1

input_dir=/speechlab/users/htl11/data/stc-data/
output_dir=../output-post-k100-fstop/
model_dir=${output_dir}model/


mkdir ${output_dir}
mkdir -p ${output_dir}model 

# the input docs for training
doc_pt=${input_dir}train.1.txt

echo "=============== Index Docs ============="
# docs after indexing
dwid_pt=${output_dir}doc_wids.txt
# vocabulary file
voca_pt=${output_dir}vocab.txt
# filtered words goes to here
filter_pt=${output_dir}filter_words.txt
python indexDocs.py $doc_pt $dwid_pt $voca_pt $fstop $filter_pt

## learning parameters p(z) and p(w|z)
echo "=============== Topic Learning ============="
W=`wc -l < $voca_pt` # vocabulary size
P=2
make -C ../src
echo "../src/btm est $K $W $P $alpha $beta $niter $save_step $dwid_pt $model_dir"
../src/btm est $K $W $P $alpha $beta $niter $save_step $dwid_pt $model_dir $has_b

## infer p(z|d) for each doc
suffix=".pz_d"
infer_type="prob"
echo "================ Infer P(z|d) ==============="
echo "../src/btm inf sum_b $K $dwid_pt $model_dir"
../src/btm inf sum_b $K $dwid_pt $model_dir $suffix $infer_type

## output top word of each topic
echo "================ Topic Display ============="
python topicAna.py $model_dir $K $voca_pt