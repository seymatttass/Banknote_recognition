import streamlit as st
import base64
import numpy as np
import cv2
from helper import classify_plant

# Base64 formatında arka plan resmini yükleme
def load_background_image(image_path):
    with open(image_path, "rb") as image_file:
        encoded_image = base64.b64encode(image_file.read()).decode()
    return encoded_image

# Streamlit uygulaması
def main():
    # Arka plan resmi ve CSS stilleri ekle
    bg_image = load_background_image('33.jpg')  # Arka plan resminin dosya adını ve yolunu buraya yazın
    page_bg_img = f'''
    <style>
    body {{
    background-image: url("data:image/jpg;base64,{bg_image}");
    background-size: cover;
    }}
    .stApp {{
        background: transparent;
    }}
    </style>
    '''
    st.markdown(page_bg_img, unsafe_allow_html=True)

    st.title("Banknot Tespit")

    # Kullanıcıdan resim seçme
    option = st.selectbox("Choose an option", ["Upload your own image", "Capture image from your phone"])

    if option == "Upload your own image":
        uploaded_file = st.file_uploader("Choose an image...", type=["jpg", "jpeg", "png"])

        if uploaded_file is not None:
            # Dosyayı oku ve işle
            image = cv2.imdecode(np.frombuffer(uploaded_file.read(), np.uint8), cv2.IMREAD_COLOR)

            # Bitki sınıflandırma işlemi
            st.header("Sonuç")
            class_name, confidence = classify_plant(image)

            if class_name is not None and confidence is not None:
                st.write(f"Class: {class_name}")
                st.write(f"Confidence: {confidence:.2f}")

                # Sınıflandırılmış resmi göster
                st.image(image, channels="BGR", use_column_width=True)
            else:
                st.write("Sınıflandırma yapılamadı. Görüntüyü ve modeli kontrol edin.")

        else:
            st.write("Lütfen bir resim yükleyin.")

    elif option == "Capture image from your phone":
        st.write("Bu seçenek şu anda geliştirme aşamasında. Lütfen daha sonra tekrar deneyin.")

if __name__ == "__main__":
    main()
