def replace_zeros_with_neighbors_mean(arr, win):
    # Iterate over the 3D array
    for i in range(arr.shape[0]):  # First dimension (72)
        for j in range(arr.shape[1]):  # Second dimension (3)
            for k in range(1, arr.shape[2] - 1):  # Third dimension (2719), avoiding edges
                if arr[i, j, k] == 0:  # If it's a zero
                    arr[i, j, k] = sum(arr[i, j, k - win:k + win]) / win  # Replace with mean of neighbors
                    
    return arr