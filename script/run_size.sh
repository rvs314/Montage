#!/bin/bash

# go to PDSHarness/script
cd "$( dirname "${BASH_SOURCE[0]}" )"
# go to PDSHarness
cd ..

outfile_dir="data"
SIZES=(16 64 256 1024 4096)
TASK_LENGTH=30 # length of each workload in second
REPEAT_NUM=3 # number of trials
SNAPSHOT_FREQ=15 # interval between two snapshot in pronto (not enabled)

delete_heap_file(){
    rm -rf /mnt/pmem/${USER}* /mnt/pmem/savitar.cat /mnt/pmem/psegments
    rm -f /mnt/pmem/*.log /mnt/pmem/snapshot*
}

queue_init(){
    echo "Running queue, 50enq 50deq for $TASK_LENGTH seconds"
    rm -rf $outfile_dir/queues_size.csv
    echo "size,thread,ops,ds,test" > $outfile_dir/queues_size.csv
}

queue_csv_prefix(){
    echo -n "sz=$1,"
    echo -n "$1," >>$outfile_dir/queues_size.csv
}

queue_execute(){
    queue_init
    # 1. All queues without epoch system
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make -j
            for rideable in {0..3} 
            do
                delete_heap_file
                queue_csv_prefix $sz
                ./bin/main -r $rideable -m0 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/queues_size.csv
            done
        done
    done

    # 2. Montage with epoch system
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make -j
            for rideable in 2 
            do
                delete_heap_file
                queue_csv_prefix $sz
                ./bin/main -r $rideable -m0 -t 1 -i $TASK_LENGTH | tee -a $outfile_dir/queues_size.csv
            done
        done
    done

    # 3. Mnemosyne queue
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make mnemosyne -j
            for rideable in 0 
            do
                delete_heap_file
                queue_csv_prefix $sz
                ./bin/main -r $rideable -m0 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/queues_size.csv
            done
        done
    done

    # 4. Pronto-full queue
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make pronto-full -j
            for rideable in 0 
            do
                delete_heap_file
                queue_csv_prefix $sz
                # ./pronto_snapshot.sh main $SNAPSHOT_FREQ &
                ./bin/main -r $rideable -m0 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/queues_size.csv
                wait
            done
        done
    done

    # 5. Pronto-sync queue
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make pronto-sync -j
            for rideable in 0 
            do
                delete_heap_file
                queue_csv_prefix $sz
                # ./pronto_snapshot.sh main $SNAPSHOT_FREQ &
                ./bin/main -r $rideable -m0 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/queues_size.csv
                wait
            done
        done
    done
}

map_init(){
    echo "Running maps, g0i50r50, g50i25r25 and g90i5r5 for $TASK_LENGTH seconds"
    rm -rf $outfile_dir/maps_g0i50r50_size.csv $outfile_dir/maps_g50i25r25_size.csv $outfile_dir/maps_g90i5r5_size.csv
    echo "size,thread,ops,ds,test" > $outfile_dir/maps_g0i50r50_size.csv
    echo "size,thread,ops,ds,test" > $outfile_dir/maps_g50i25r25_size.csv
    echo "size,thread,ops,ds,test" > $outfile_dir/maps_g90i5r5_size.csv
}

map_execute(){
    map_init
    # 1. All maps without epoch system
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make -j
            for rideable in {7..12} 
            do
                delete_heap_file
                echo -n "g0i50r50,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g0i50r50_size.csv
                ./bin/main -r $rideable -m 2 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g0i50r50_size.csv

                delete_heap_file
                echo -n "g50i25r25,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g50i25r25_size.csv
                ./bin/main -r $rideable -m 3 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g50i25r25_size.csv

                delete_heap_file
                echo -n "g90i5r5,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g90i5r5_size.csv
                ./bin/main -r $rideable -m 4 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g90i5r5_size.csv
            done
        done
    done

    # 2. Montage with epoch system
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make -j
            for rideable in 10 
            do
                delete_heap_file
                echo -n "g0i50r50,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g0i50r50_size.csv
                ./bin/main -r $rideable -m 2 -t 1 -i $TASK_LENGTH | tee -a $outfile_dir/maps_g0i50r50_size.csv

                delete_heap_file
                echo -n "g50i25r25,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g50i25r25_size.csv
                ./bin/main -r $rideable -m 3 -t 1 -i $TASK_LENGTH | tee -a $outfile_dir/maps_g50i25r25_size.csv

                delete_heap_file
                echo -n "g90i5r5,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g90i5r5_size.csv
                ./bin/main -r $rideable -m 4 -t 1 -i $TASK_LENGTH | tee -a $outfile_dir/maps_g90i5r5_size.csv
            done
        done
    done

    # 3. Mnemosyne map
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make mnemosyne -j
            for rideable in 1 
            do
                delete_heap_file
                echo -n "g0i50r50,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g0i50r50_size.csv
                ./bin/main -r $rideable -m 2 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g0i50r50_size.csv

                delete_heap_file
                echo -n "g50i25r25,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g50i25r25_size.csv
                ./bin/main -r $rideable -m 3 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g50i25r25_size.csv

                delete_heap_file
                echo -n "g90i5r5,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g90i5r5_size.csv
                ./bin/main -r $rideable -m 4 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g90i5r5_size.csv
            done
        done
    done


    # 4. Pronto-full map
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make pronto-full -j
            for rideable in 1 
            do
                delete_heap_file
                echo -n "g0i50r50,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g0i50r50_size.csv
                ./bin/main -r $rideable -m 2 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g0i50r50_size.csv
                wait

                delete_heap_file
                echo -n "g50i25r25,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g50i25r25_size.csv
                ./bin/main -r $rideable -m 3 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g50i25r25_size.csv
                wait

                delete_heap_file
                echo -n "g90i5r5,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g90i5r5_size.csv
                ./bin/main -r $rideable -m 4 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g90i5r5_size.csv
                wait
            done
        done
    done

    # 5. Pronto-sync map
    for ((i=1; i<=REPEAT_NUM; ++i))
    do
        for sz in "${SIZES[@]}"
        do
            make clean;V_SZ=$sz make pronto-sync -j
            for rideable in 1 
            do
                delete_heap_file
                echo -n "g0i50r50,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g0i50r50_size.csv
                ./bin/main -r $rideable -m 2 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g0i50r50_size.csv
                wait

                delete_heap_file
                echo -n "g50i25r25,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g50i25r25_size.csv
                ./bin/main -r $rideable -m 3 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g50i25r25_size.csv
                wait

                delete_heap_file
                echo -n "g90i5r5,sz=$sz,"
                echo -n "$sz," >>$outfile_dir/maps_g90i5r5_size.csv
                ./bin/main -r $rideable -m 4 -t 1 -dPersistStrat=No -i $TASK_LENGTH | tee -a $outfile_dir/maps_g90i5r5_size.csv
                wait
            done
        done
    done

}

########################
###       Main       ###
########################
queue_execute
map_execute

