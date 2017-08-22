#!/bin/sh
#服务名
serviceName=
#函数名
functionName=
#内存大小
memorySize=
#运行环境
runtimetype=
#超时时间
timeout=
#handler nodejs中指的是module的入口
fchandler=

ossutilDownloadUrl=http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/attach/50452/cn_zh/1502070288777/ossutil64?spm=5176.doc50452.2.3.C0jKlt
fcliDownloadUrl=https://gosspublic.alicdn.com/fcli/fcli-v0.8-linux-amd64.zip
first="false"
if [ ! -f "ossutil" ]; then
first="true"
wget $ossutilDownloadUrl
mv ossutil* ossutil
chmod 777 ossutil
wget $fcliDownloadUrl
unzip fcli*
rm fcli-*
chmod 777 fcli
fi
#写入 properties
echo accesskey=$ALIYUN_ACCESS_KEY_ID > ./properties
echo accesskeySecret=$ALIYUN_ACCESS_KEY_SECRET >> ./properties
echo endpoint=$ALIYUN_FC_ENDPOINT >> ./properties
echo fc_bucket=$FC_BUCKET >> ./properties
echo ossRegion=$OSS_REGIOBN >> ./properties

file_list=$(ls -a | grep -v  ossutil | grep -v fcil | grep -v fcbuilder)
fl=${file_list:5}
zip -r $functionName.zip $fl
./fcli config --access-key-id $ALIYUN_ACCESS_KEY_ID --access-key-secret $ALIYUN_ACCESS_KEY_SECRET --endpoint $ALIYUN_FC_ENDPOINT
if [ "$first" = "true" ] ; then
./ossutil -i $ALIYUN_ACCESS_KEY_ID -k $ALIYUN_ACCESS_KEY_SECRET -e $ALIYUN_OSS_ENDPOINT  cp $functionName.zip  oss://$FC_BUCKET/$functionName.zip
./fcli function create --code-bucket $FC_BUCKET -o $functionName.zip -s $serviceName -f $functionName -m $memorySize -t $runtimetype --timeout $timeout --handler $fchandler
else
./ossutil -i $ALIYUN_ACCESS_KEY_ID -k $ALIYUN_ACCESS_KEY_SECRET -e $ALIYUN_OSS_ENDPOINT  --force cp $functionName.zip  oss://$FC_BUCKET/$functionName.zip
./fcli function update --bucket $FC_BUCKET  -o $functionName.zip -s $serviceName -f $functionName -m $memorySize -t $runtimetype --timeout $timeout --handler $fchandler
fi

