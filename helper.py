import cv2
import numpy as np
import tensorflow as tf
from PIL import Image
import io

# Model yolu
model_path = r'C:\c_masaüstü\1.py\models\ınception_model_1'

try:
    # SavedModel yükleme
    model = tf.saved_model.load(model_path)

    # Modelin servis örneğini alın
    model_fn = model.signatures['serving_default']

    # Modelin iç yapısını incele
    print(model.signatures['serving_default'])

except Exception as e:
    print(f"Model yükleme hatası: {e}")

# Bitki sınıflandırma fonksiyonu
def classify_plant(image_file):
    try:
        # Görüntüyü model için hazırlama
        print("Görüntü işleme başladı.")
        image = Image.open(image_file)
        image = image.convert('RGB')
        image = np.array(image)
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        image = cv2.resize(image, (299, 299))
        image = img_to_array_opencv(image)
        image = preprocess_input_opencv(image)
        print("Görüntü başarıyla hazırlandı.")

        # Sınıflandırma işlemi
        print("Model tahmin işlemi başladı.")
        output = model_fn(tf.constant(image))
        predictions = output['dense_1']  # TensorFlow modelinin doğru çıkış adını kullanın

        print(f"Predictions: {predictions}")

        class_index = np.argmax(predictions)
        confidence = predictions[0][class_index]

        # Sınıf adları (model eğitimi sırasında kullanılan sınıf adlarını buraya ekleyin)
        class_names = ['10 TL', '50 TL', '200 TL', '20 TL', '100 TL', '5 TL']

        class_name = class_names[class_index]
        print(f"Sınıflandırma tamamlandı: {class_name} ({confidence:.2f})")
        return class_name, confidence

    except Exception as e:
        print(f"Sınıflandırma hatası: {e}")
        return None, None

# OpenCV ile img_to_array kullanımı
def img_to_array_opencv(image):
    img_array = np.array(image, dtype=np.float32)
    return img_array

# OpenCV ile preprocess_input kullanımı
def preprocess_input_opencv(image):
    # Giriş tipini float32'ye dönüştürme ve [0, 1] aralığına normalleştirme
    image /= 255.0
    image = np.expand_dims(image, axis=0)  # Batch boyutunu eklemek için boyutu genişletme
    return image