from red_flags import detect_red_flags


tests = [
    "mere seene mein dard hai",
    "mere seene mein dard hai aur saans lene mein dikkat hai",
    "mera haath achanak kamzor ho gaya",
    "mujhe bukhar hai",
    "mujhe cough hai"
]


for text in tests:

    result = detect_red_flags(text)

    print("\nPatient:", text)
    print("Result:", result)