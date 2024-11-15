def replace_zeros_with_mean(arr):
    # Create a copy to avoid modifying the original array
    result = arr.copy()
    for i in range(1, len(arr) - 1):
        if arr[i] == 0:
            result[i] = (arr[i - 1] + arr[i + 1]) / 2
    return result