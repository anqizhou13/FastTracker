def batch_process_c3d(data_folder):

    import c3d 
    import numpy as np
    import math
    import glob
    import os
    import time
    import minitools

    # Search for files with 'GAIT' in their name and '.c3d' extension, recursively
    files = glob.glob(f'{data_folder}/**/*GAIT*.c3d', recursive=True)
    
    labels = []
    time_series_raw = []
    time_series_ego = []
    time_series_ego_norm = []
    bad_files = []

    for n, file in enumerate(files):

        startTime = time.time()
        print('Processing {} of {} files...'.format(n,len(files)))
        # for each file
        # time each iteration

        with open(file, 'rb') as f:
            reader = c3d.Reader(f)

            for frame in reader.read_frames():
                for point in frame['points']:
                    # Ensure that values are within the expected range for uint16
                    point = np.clip(point, 0, 65535)  # Clip values to prevent overflow
        
            # Initialize data structures to store extracted data
            markers = []

            # Iterate over frames
            #for i, (points, analog) in enumerate(reader.read_frames()):
            for i, points in enumerate(reader.read_frames()):
                markers.append(points[1][:,:3])  # Extract 3D positions (x, y, z), which are the first three values stored in the 1st tuple position
                #analog_data.append(analog)    # Extract analog signals (e.g., force plates)

            # Convert to numpy arrays for easier manipulation
            markers = np.array(markers)        # Shape: (frames, markers, (x,y,z))
            markers = np.transpose(markers, (1, 2, 0)) # change the shape so that it is (markers, (x,y,z), frames)

            # if a c3d file is somehow empty and has no annotated tracker data
            if markers.size == 0:  
                bad_files.append(file) # note that the file is deprecated
                print('{} Deprecated, skipping'.format(file))
                continue  # Skip the current iteration
            

            # find indices along the 1st dim of the markers array to find labels that are already annotated
            # untraced marker labels are numbered with asterisks (e.g. *36, *37)
            marker_indices = [i for i, element in enumerate(reader.point_labels) if '*' not in element]
            # keep only the labeled markers
            markers = markers[marker_indices]

            # clean the data a bit--jumping 0 values due to brief loss of markers, 
            # let's replace those 0s with mean of 1 frame before and 1 frame after
            markers = minitools.replace_zeros_with_neighbors_mean(markers,1)

            
            # store the raw data into lists
            labels.append(reader.point_labels[marker_indices])
            time_series_raw.append(markers)

            # now compute egocentric measurements of marker data
            # find the center of mass assuming that markers are uniformly distributed around the center
            center = np.mean(markers, axis=0)

            # transform marker data
            ego = []
            for i in range(len(reader.point_labels[marker_indices])):
                ego.append(markers[i] - center) # compute euclidean distance
            ego = np.array(ego)
            # store it
            time_series_ego.append(ego)

            # now normalize the measurements by the size of vector
            magnitude=[]
            for i in range(len(reader.point_labels[marker_indices])):
                for t in range(len(ego[i,0])):
                    # compute square root of sum of squares across position for all axes
                    # to compute magnitude of the vector
                    magnitude.append(math.hypot(ego[i,0,t], ego[i,1,t], ego[i,2,t]))
            magnitude = np.reshape(np.array(magnitude),(len(reader.point_labels[marker_indices]),len(ego[i,0])))
            # broadcast and normalize the coordinates
            ego_normalized = np.array(ego/magnitude[:,np.newaxis,:])
            time_series_ego_norm.append(ego_normalized)

            endTime = time.time()
            runTime = endTime - startTime
            print(" File processed, runtime {} seconds ".format(runTime))
    return labels, time_series_raw, time_series_ego, time_series_ego_norm, bad_files