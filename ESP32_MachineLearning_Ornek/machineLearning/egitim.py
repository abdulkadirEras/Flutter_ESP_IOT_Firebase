import tensorflow as tf
from tensorflow import keras


# Giriş şeklinin ivmeölçerin x, y, z değerlerini temsil eden (3,) olduğunu varsayalım
model = keras.Sequential([
    keras.layers.InputLayer(input_shape=(3,)),
    keras.layers.Dense(16, activation='relu'),
    keras.layers.Dense(16, activation='relu'),
    keras.layers.Dense(3, activation='softmax')  # 3 eksen için 3 çıkış
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])


model.fit(train_data, train_labels, epochs=10)# Modeli önceden işlenmiş sensör verilerile eğit


model.save("gesture_model.h5")# modeli kaydet