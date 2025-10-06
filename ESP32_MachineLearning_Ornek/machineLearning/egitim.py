import tensorflow as tf
from tensorflow import keras


# Assume input shape is (3,) representing x, y, z values of accelerometer
model = keras.Sequential([
    keras.layers.InputLayer(input_shape=(3,)),
    keras.layers.Dense(16, activation='relu'),
    keras.layers.Dense(16, activation='relu'),
    keras.layers.Dense(3, activation='softmax')  # 3 output classes for 3 gestures
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Train the model with your preprocessed sensor data
model.fit(train_data, train_labels, epochs=10)

# Save the model
model.save("gesture_model.h5")