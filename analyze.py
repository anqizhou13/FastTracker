def batch_process_c3d(data_folder):

    # input: path to data folder
    # output:
        # for each c3d file, a pickle file containing
            # markers_all - an ndarray containing all markers data, including unlabeled traces
            # labels_all - a list of all labels, including unannotated labels
        # for the whole data folder, a pickle file containing
            # labels - concatenated list of all annotated labels from all c3d files
            # time_series_raw - same as markers_all but including only traces with annotated labels, concatenanted over all c3d files
            # time_series_ego - distance in x,y,z of all annotate markers from center of mass (which is assumed to be the mean of all markers)
            # time_series_ego_norm - normalized by vector length
            # bad_files - path of files that were not processed due to deprecated marker data or are completely unlabeled

    from ezc3d import c3d
    import pickle 
    import numpy as np
    import math
    import glob
    import os
    import time
    import minitools

    # Search for files with 'GAIT' in their name and '.c3d' extension, recursively
    files = glob.glob(f'{data_folder}/**/*GAIT*.c3d', recursive=True)
    
    labels_all_files = []
    time_series_raw = []
    time_series_ego = []
    time_series_ego_norm = []
    bad_files = []

    for n, file in enumerate(files):

        startTime = time.time()
        print('Processing {} of {} files...'.format(n,len(files)))
        # for each file
        # time each iteration

        c = c3d(file)
        # retrieve the first 3 dim (x,y,z), 
        # note that this ndarray originally has 4 dim (x,y,z,1), 1 for analog
        markers_all = c['data']['points'][0:3,] 
        # change the shape so that it is (N_markers, (x,y,z), N_frames)
        markers_all = np.transpose(markers_all, (1, 0, 2)) 
        labels_all = list(c['parameters']['POINT']['LABELS'].values())[-1] # retrieve labels as a list

        # if a c3d file is somehow empty and has no annotated tracker data
        if markers_all.size == 0:  
            bad_files.append(file) # note that the file is deprecated
            print('{} Deprecated or non-annotated, skipping'.format(file))
            continue  # Skip the current iteration

        # save the raw time series and labels into a pickle file
        
        print('Pickling raw time series...')
        pickle_path = file+'_raw_time_series.pkl'
        with open(pickle_path, "wb") as f:  
            pickle.dump((markers_all,labels_all,), f)

        # find indices along the 1st dim of the markers array to find labels that are already annotated
        # untraced marker labels are numbered with asterisks (e.g. *36, *37)
        marker_indices = [i for i, element in enumerate(labels_all) if '*' not in element]
        # keep only the labeled markers
        labels = [labels_all[i] for i in marker_indices]
        labels_all_files.append(labels)
        markers = markers_all[marker_indices]

        # clean the data a bit--jumping 0 values due to brief loss of markers (generally for 1 frame), 
        # let's replace those 0s with mean of 1 frame before and 1 frame after
        markers = minitools.replace_zeros_with_neighbors_mean(markers,1)
        time_series_raw.append(markers)

        # now compute egocentric measurements of marker data
        # find the center of mass assuming that markers are uniformly distributed around the center
        center = np.nanmean(markers, axis=0)

        # transform marker data
        ego = []
        for i in range(len(labels)):
            ego.append(markers[i] - center) # compute euclidean distance
        ego = np.array(ego)
        # store it
        time_series_ego.append(ego)

        # now normalize the measurements by the size of vector
        magnitude=[]
        for i in range(len(labels)): # for each marker
            for t in range(len(ego[i,0])): # at each frame
                # compute square root of sum of squares across position for all axes
                # to compute magnitude of the vector
                magnitude.append(math.hypot(ego[i,0,t], ego[i,1,t], ego[i,2,t]))
        magnitude = np.reshape(np.array(magnitude),(len(labels),len(ego[i,0])))
        # broadcast and normalize the coordinates
        ego_normalized = np.array(ego/magnitude[:,np.newaxis,:])
        time_series_ego_norm.append(ego_normalized)

        endTime = time.time()
        runTime = endTime - startTime
        print('Run time: {}s'.format(runTime))

    #if pickle_output:
        #print('Pickling everything together ...')
        #pickle_path = data_folder+'/data_concatenated.pkl'
        #with open(pickle_path, "wb") as f:  
        #    pickle.dump((labels_all_files, time_series_raw, time_series_ego, time_series_ego_norm, bad_files), f)
    return labels_all_files, time_series_raw, time_series_ego, time_series_ego_norm, bad_files