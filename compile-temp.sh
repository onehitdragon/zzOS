# # sector 16th
# echo -n -e "sector16\r\n" | dd of=./build/main.img bs=1 seek=$((512 * 16)) count=10 conv=notrunc
# # sector 17th
# echo -n -e "sector17\r\n" | dd of=./build/main.img bs=1 seek=$((512 * 17)) count=10 conv=notrunc
# # sector 18th
# echo -n -e "sector18\r\n" | dd of=./build/main.img bs=1 seek=$((512 * 18)) count=10 conv=notrunc
# sector 65th
# echo -n -e "sector" | dd of=./build/main.img bs=1 seek=$((512 * 20)) count=6 conv=notrunc

# for i in {65..65}
# do
#     data="sectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsectorsector$i\r\n"
#     echo -n -e $data | dd of=./build/main.img bs=1 \
#         seek=$((512 * $i)) \
#         count=$((${#data} - 2)) \
#         conv=notrunc
# done
# # log
# ls -l ./build/main.img