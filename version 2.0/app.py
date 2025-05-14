import os
import psycopg2
import tensorflow as tf
import numpy as np
from PIL import Image
from flask import Flask, request, jsonify, render_template
import io

app = Flask(__name__)

# --- Configuration ---
DB_HOST = "localhost"
DB_NAME = "DBMS Project"
DB_USER = "postgres"
DB_PASSWORD = "pgadmin4"
DB_PORT = "5432"

# --- IMPORTANT: Update these paths to the correct locations of your files ---
MODEL_PATH = r"D:\\4th semester GIKI\\CS-232 (DBMS)\\Project\\DBMSPROJECT\\AI-Based-Medicine-Recognition-and-Sorting-Tool\\version 1.0\\model_unquant.tflite"
LABELS_PATH = r"D:\\4th semester GIKI\\CS-232 (DBMS)\\Project\\DBMSPROJECT\\AI-Based-Medicine-Recognition-and-Sorting-Tool\\version 1.0\\labels.txt"
UPLOAD_FOLDER = os.path.join('static', 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# --- Load TFLite Model and Labels ---
try:
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    MODEL_INPUT_HEIGHT = input_details[0]['shape'][1]
    MODEL_INPUT_WIDTH = input_details[0]['shape'][2]
    with open(LABELS_PATH, 'r') as f:
        labels = [line.strip() for line in f.readlines()]
    print("TensorFlow Lite model and labels loaded successfully.")
except Exception as e:
    print(f"Error loading model/labels: {e}")
    interpreter = None
    labels = []
    MODEL_INPUT_HEIGHT = 224
    MODEL_INPUT_WIDTH = 224

# --- Database Connection ---
def get_db_connection():
    conn = None
    try:
        conn = psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASSWORD, port=DB_PORT)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

# --- Image Preprocessing and Prediction ---
def preprocess_image(image_bytes, target_height, target_width):
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        img = img.resize((target_width, target_height))
        img_array = np.array(img, dtype=np.float32)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = img_array / 255.0
        return img_array
    except Exception as e:
        print(f"Error preprocessing image: {e}")
        return None

def predict_medicine(image_bytes):
    if interpreter is None or not labels:
        return "Model not loaded", 0.0
    processed_image = preprocess_image(image_bytes, MODEL_INPUT_HEIGHT, MODEL_INPUT_WIDTH)
    if processed_image is None:
        return "Error processing image", 0.0
    interpreter.set_tensor(input_details[0]['index'], processed_image)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])
    prediction_index = np.argmax(output_data[0])
    confidence = float(output_data[0][prediction_index])
    predicted_label = labels[prediction_index]
    return predicted_label, confidence

# --- Flask Routes ---

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/detect', methods=['GET', 'POST'])
def detect():
    if request.method == 'POST':
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided.'}), 400
        file = request.files['image']
        if file.filename == '':
            return jsonify({'error': 'No image selected.'}), 400

        if file:
            try:
                image_bytes = file.read()
                predicted_name, confidence = predict_medicine(image_bytes)

                if predicted_name == "Error processing image" or predicted_name == "Model not loaded":
                    return jsonify({'error': predicted_name}), 500

                conn = get_db_connection()
                if not conn:
                    return jsonify({'error': 'Database connection failed.'}), 500
                cur = conn.cursor()
                #  Crucially, this query is designed to work with your provided schema:
                cur.execute("""
                    SELECT
                        m.name AS medicine_name,
                        c.category_name AS category,
                        df.form_name AS dosage_form,
                        m.used_for,
                        STRING_AGG(DISTINCT i.indication_name, ', ') AS indications,
                        STRING_AGG(DISTINCT se.effect_description, ', ') AS side_effects
                    FROM medicines m
                    LEFT JOIN categories c ON m.category_id = c.category_id
                    LEFT JOIN dosage_forms df ON m.dosage_form_id = df.form_id
                    LEFT JOIN medicine_indications mi ON m.medicine_id = mi.medicine_id
                    LEFT JOIN indications i ON mi.indication_id = i.indication_id
                    LEFT JOIN medicine_side_effects mse ON m.medicine_id = mse.medicine_id
                    LEFT JOIN side_effects se ON mse.side_effect_id = se.side_effect_id
                    WHERE m.name ILIKE %s
                    GROUP BY m.medicine_id, m.name, c.category_name, df.form_name, m.used_for;
                """, (predicted_name,))
                medicine_details = cur.fetchone()
                cur.close()
                conn.close()

                import base64
                base64_image = base64.b64encode(image_bytes).decode('utf-8')
                image_url = f"data:image/jpeg;base64,{base64_image}"

                if medicine_details:
                    return jsonify({
                        'predicted_name': predicted_name,
                        'confidence': f"{confidence * 100:.2f}%",
                        'medicine_details': {
                            'medicine_name': medicine_details[0],
                            'category': medicine_details[1],
                            'dosage_form': medicine_details[2],
                            'used_for': medicine_details[3],
                            'indications': medicine_details[4] if medicine_details[4] else 'N/A',
                            'side_effects': medicine_details[5] if medicine_details[5] else 'N/A'
                        },
                        'image_url': image_url
                    })
                else:
                    return jsonify({
                        'predicted_name': predicted_name,
                        'confidence': f"{confidence * 100:.2f}%",
                        'medicine_details': None,
                        'message': 'Medicine recognized, but details not found in database.',
                        'image_url': image_url
                    })

            except Exception as e:
                print(f"Error in /detect route: {e}")
                return jsonify({'error': f'An server error occurred: {str(e)}'}), 500

    return render_template('detect.html')

@app.route('/details')
def details(): # Changed function name
    return render_template('details.html')

@app.route('/medicine/<path:name>')
def get_medicine(name): # Changed function name
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed.'}), 500

    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT
                m.name AS medicine_name,
                c.category_name AS category,
                df.form_name AS dosage_form,
                m.used_for,
                STRING_AGG(DISTINCT i.indication_name, ', ') AS indications,
                STRING_AGG(DISTINCT se.effect_description, ', ') AS side_effects
            FROM medicines m
            LEFT JOIN categories c ON m.category_id = c.category_id
            LEFT JOIN dosage_forms df ON m.dosage_form_id = df.form_id
            LEFT JOIN medicine_indications mi ON m.medicine_id = mi.medicine_id
            LEFT JOIN indications i ON mi.indication_id = i.indication_id
            LEFT JOIN medicine_side_effects mse ON m.medicine_id = mse.medicine_id
            LEFT JOIN side_effects se ON mse.side_effect_id = se.side_effect_id
            WHERE m.name ILIKE %s
            GROUP BY m.medicine_id, m.name, c.category_name, df.form_name, m.used_for;
        """, (name,))
        medicine_details = cur.fetchone()
        cur.close()
        conn.close()

        if medicine_details:
            return jsonify({
                'name': medicine_details[0],
                'category': medicine_details[1],
                'dosage_form': medicine_details[2],
                'used_for': medicine_details[3],
                'indications': medicine_details[4].split(', ') if medicine_details[4] else [],
                'side_effects': medicine_details[5].split(', ') if medicine_details[5] else []
            })
        else:
            return jsonify({'error': 'Medicine not found'}), 404

    except Exception as e:
        print(f"Error in /medicine route: {e}")
        return jsonify({'error': f'An error occurred while fetching details: {str(e)}'}), 500

@app.route('/indication')
def indication(): # This route serves the HTML page
    return render_template('indication.html')

@app.route('/search_by_indication') # This route handles the search API request
def search_by_indication():
    indication = request.args.get('indication')
    if not indication:
        return jsonify({'error': 'Indication parameter is missing'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed.'}), 500

    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT
                m.name AS medicine_name,
                c.category_name AS category,
                df.form_name AS dosage_form,
                m.used_for
            FROM medicines m
            JOIN medicine_indications mi ON m.medicine_id = mi.medicine_id
            JOIN indications i ON mi.indication_id = i.indication_id
            LEFT JOIN categories c ON m.category_id = c.category_id
            LEFT JOIN dosage_forms df ON m.dosage_form_id = df.form_id
            WHERE i.indication_name ILIKE %s
        """, (f'%{indication}%',))
        recommendations = cur.fetchall()
        cur.close()
        conn.close()

        medicines_for_indication = [row[0] for row in recommendations]
        return jsonify({'medicines_for_indication': medicines_for_indication})

    except Exception as e:
        print(f"Error in /search_by_indication route: {e}")
        return jsonify({'error': f'An error occurred while searching by indication: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)