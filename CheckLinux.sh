#!/bin/bash
echo "----------------------------------- C P U 信 息 -------------------------------------------------"
#CPU型号：
cpu_model=`cat /proc/cpuinfo | grep "model name" | awk -F ':' '{print $2}' | sort | uniq`
echo "CPU型号：$cpu_model"

#CPU架构
cpu_architecture=`uname -m`
echo "CPU架构：$cpu_architecture"

#物理CPU个数
cpu_phy_num=`cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l`
echo "物理CPU个数：$cpu_phy_num"

#CPU核数
cpu_core_num=`cat /proc/cpuinfo | grep "cpu cores" | uniq | awk -F ': ' '{print $2}'`
echo "CPU核数：$cpu_core_num"

#逻辑CPU个数
cpu_proc_num=`cat /proc/cpuinfo | grep "processor" | uniq | wc -l`
echo "逻辑CPU个数：$cpu_proc_num"

##CPU主频
cpu_main_freq=`cat /proc/cpuinfo | grep "model name" | awk -F '@' 'NR==1 {print $2}'`
echo "CPU主频：$cpu_main_freq"

##L1d缓存
cpu_l1d_cache=`lscpu | grep -i 'L1d 缓存\|L1d cache' | awk -F '：|:' '{print $2}'`
echo "L1d缓存：$cpu_l1d_cache"

##L1i缓存
cpu_l1i_cache=`lscpu | grep -i 'L1i 缓存\|L1i cache' | awk -F '：|:' '{print $2}'`
echo "L1i缓存：$cpu_l1i_cache"

##L2缓存
cpu_l2_cache=`lscpu | grep -i 'L2 缓存\|L2 cache' | awk -F '：|:' '{print $2}'`
echo "L2缓存：$cpu_l2_cache"

##L3缓存
cpu_l3_cache=`lscpu | grep -i 'L3 缓存\|L3 cache' | awk -F '：|:' '{print $2}'`
echo "L3缓存：$cpu_l3_cache"

#操作系统名称
system_name=`head -n 1 /etc/issue | awk '{print $1,$2}'`
echo "操作系统名称：$system_name"

#操作系统位数
systembit=`getconf LONG_BIT`
echo "操作系统位数：$systembit"

#操作系统内核版本
system_kernel=`uname -r`
echo "操作系统内核版本：$system_kernel"


#物理内存容量
meminfo=`sudo dmidecode | grep "^[[:space:]]*Size.*MB$" | uniq -c | sed 's/ \t*Size: /\*/g' | sed 's/^ *//g'`
echo "$meminfo"

#单位转换函数
function convert_unit()
{
	result=$1
	if [ $result -ge  1048576 ]
	then
		value=1048576 #1024*1024	
		result_gb=$(awk 'BEGIN{printf"%.2f\n",'$result' / '$value'}') #将KB转换成GB，并保留2位小数
		echo $result_gb"GB"
	elif [ $result -ge  1024 ]
	then
		value=1024 	
		result_mb=$(awk 'BEGIN{printf"%.2f\n",'$result' / '$value'}') #将KB转换成MB，并保留2位小数
		echo $result_mb"MB"
	else
		echo $result"KB"
	fi
}

#单位：KB
echo "-------------------------------- 物 理 内 存 容 量 信 息 -----------------------------------------"
MemTotal=$(cat /proc/meminfo | awk '/^MemTotal/{print $2}') #内存总量
MemFree=$(cat /proc/meminfo | awk '/^MemFree/{print $2}')   #空闲内存
MemUsed=$(expr $MemTotal - $MemFree)  #已用内存

##计算内存占用率

Mem_Rate=$(awk 'BEGIN{printf"%.2f\n",'$MemUsed' / '$MemTotal' *100}') #保留小数点后2位

MemShared=$(cat /proc/meminfo | awk '/^Shmem/{print $2}') #共享内存

Buffers=$(cat /proc/meminfo | awk '/^Buffers/{print $2}') #文件缓冲区

Cached=$(cat /proc/meminfo | awk '/^Cached/{print $2}') #用于高速缓冲存储器


SwapTotal=$(cat /proc/meminfo | awk '/^SwapTotal/{print $2}') #交换区总量

SwapFree=$(cat /proc/meminfo | awk '/^SwapFree/{print $2}') #空闲交换区

Mapped=$(cat /proc/meminfo | awk '/^Mapped/{print $2}') #已映射

##虚拟内存

VmallocUsed=$(cat /proc/meminfo | awk '/^VmallocUsed/{print $2}') #已使用的虚拟内存

echo "内存总量：$(convert_unit $MemTotal)"
echo "空闲内存：$(convert_unit $MemFree)"
echo "已用内存$(convert_unit $MemUsed)"
echo "内存占用率：$Mem_Rate%"
echo "共享内存：$(convert_unit $MemShared)"
echo "文件缓冲区：$(convert_unit $Buffers)"
echo "用于高速缓冲存储器：$(convert_unit $Cached)"
echo "交换区总量：$(convert_unit $SwapTotal)"
echo "空闲交换区：$(convert_unit $SwapFree)"
echo "已映射：$(convert_unit $Mapped)"
echo "已使用的虚拟内存：$(convert_unit $VmallocUsed)"


#磁盘型号
echo "------------------------------------- 磁 盘 ------------------------------------------------------"
disk_model=`fdisk -l | grep "Disk model" | awk -F : '{print $2}' | sed 's/^ //'`
echo "磁盘型号:$disk_model"

usesum=0
totalsum=0
disknum=`df -hlT |wc -l `
for((n=2;n<=$disknum;n++))
do
	use=$(df -k |awk NR==$n'{print int($3)}')
	pertotal=$(df -k |awk NR==$n'{print int($2)}')
	usesum=$[$usesum+$use]		#计算已使用的总量
	totalsum=$[$totalsum+$pertotal]	#计算总量
done
freesum=$[$totalsum-$usesum]
diskutil=$(awk 'BEGIN{printf"%.2f\n",'$usesum' / '$totalsum'*100}')
freeutil=$(awk 'BEGIN{printf"%.2f\n",100 - '$diskutil'}')

#磁盘总量
if [ $totalsum -ge 0 -a $totalsum -lt 1024 ];then
echo "磁盘总量:$totalsum K"

elif [ $totalsum -gt 1024 -a  $totalsum -lt 1048576 ];then
	totalsum=$(awk 'BEGIN{printf"%.2f\n",'$totalsum' / 1024}')
echo "磁盘总量:$totalsum M"

elif [ $totalsum -gt 1048576 ];then
	totalsum=$(awk 'BEGIN{printf"%.2f\n",'$totalsum' / 1048576}')
echo "磁盘总量:$totalsum G"

fi

#磁盘已使用总量
if [ $usesum -ge 0 -a $usesum -lt 1024 ];then
echo "磁盘已使用总量:$usesum K"

elif [ $usesum -gt 1024 -a  $usesum -lt 1048576 ];then
	usesum=$(awk 'BEGIN{printf"%.2f\n",'$usesum' / 1024}')
echo "磁盘已使用总量:$usesum M"

elif [ $usesum -gt 1048576 ];then
	usesum=$(awk 'BEGIN{printf"%.2f\n",'$usesum' / 1048576}')
echo "磁盘已使用总量:$usesum G"

fi

#磁盘未使用总量
if [ $freesum -ge 0 -a $freesum -lt 1024 ];then
echo "磁盘未使用总量:$freesum K"

elif [ $freesum -gt 1024 -a  $freesum -lt 1048576 ];then
	freesum=$(awk 'BEGIN{printf"%.2f\n",'$freesum' / 1024}')
echo "磁盘未使用总量:$freesum M"

elif [ $freesum -gt 1048576 ];then
	freesum=$(awk 'BEGIN{printf"%.2f\n",'$freesum' / 1048576}')
echo "磁盘未使用总量:$freesum G"
fi

#磁盘占用率
echo "磁盘占用率:$diskutil%"

#磁盘空闲率
echo "磁盘空闲率:$freeutil%"

echo "----------------------------------- G P U 信 息 --------------------------------------------------"
#显卡型号
graphicscardmodel=`lspci | grep -i 'VGA' | sed '2d' | cut -f3 -d ":" | sed 's/([^>]*)//g'`
echo "显卡型号:$graphicscardmodel"

#显卡生产商
graphicscardmanufacturer=`lspci | grep -i 'VGA'| sed '2d'| awk '{ print $5,$6 }'`
echo "显卡生产商:$graphicscardmanufacturer"


echo "----------------------------------- 主 板 信 息 --------------------------------------------------"
#主板厂商
boardmanufacturer=`sudo dmidecode | grep -A 10 "Base Board Information" |grep "Manufacturer" | awk -F ':' '{print $2}'`
echo "主板厂商:$boardmanufacturer"

#主板名称
boardname=`sudo dmidecode | grep -A 10 "Base Board Information" |grep "Product Name" | awk -F ':' '{print $2}'`
echo "主板名称；$boardname"

#BIOS厂商
biosvendor=`sudo dmidecode | grep -A 28 "BIOS Information" | grep 'Vendor' | awk -F ':' '{print $2}'`
echo "BIOS厂商：$biosvendor"

#BIOS版本
biosversion=`sudo dmidecode | grep -A 28 "BIOS Information" | grep 'Version' | awk -F ':' '{print $2}'`
echo "BIOS版本：$biosversion"

#BIOS发行日期
biosrelease=`sudo dmidecode | grep -A 28 "BIOS Information" | grep 'Release' | awk -F ':' '{print $2}'`
echo "BIOS发行日期：$biosrelease"

#网卡信息
netcardinfo=`lspci | grep -i eth | head -n +1 | awk -F : '{print $3}' | sed 's/^ //'`
echo "网卡信息：$netcardinfo"
