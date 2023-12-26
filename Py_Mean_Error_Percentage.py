def calculate_mape(actual, predicted):
    if len(actual) != len(predicted):
        raise ValueError("Lengths of actual and predicted lists must be the same.")
    
    n = len(actual)
    absolute_percentage_errors = []

    for i in range(n):
        actual_value = actual[i]
        predicted_value = predicted[i]
        
        if actual_value == 0:
            raise ValueError("Actual value cannot be zero for MAPE calculation.")
        
        absolute_percentage_error = abs((actual_value - predicted_value) / actual_value)
        absolute_percentage_errors.append(absolute_percentage_error)
    mape = (sum(absolute_percentage_errors) / n) * 100
    return mape

# Example usage:
actual_values = [2.0000000000000013, -5.0000000000000044, -2.0000000000000000, 2.9999999999999982, -6.0000000000000027]
predicted_values = [2.000000, -5.000001, -2.000000, 3.000000, -6.000001]

mape = calculate_mape(actual_values, predicted_values)
print(f"Mean Absolute Percentage Error (MAPE): {mape}%")
