from flask import Flask, request, jsonify
from flask import send_from_directory
import psycopg2
import tensorflow as tf
import numpy as np
from PIL import Image
import io

app = Flask(__name__)

@app.route("/")
def index():
    return send_from_directory(".", "index.html")

# ---- PostgreSQL DB Connection ----
conn = psycopg2.connect(
    dbname="DBMS Project",
    user="postgres",
    password="pgadmin4",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

# ---- Load TFLite Model ----
interpreter = tf.lite.Interpreter(model_path="model_unquant.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# ---- Load Labels ----
with open("labels", "r") as f:
    labels = [line.strip() for line in f.readlines()]

# ---- Preprocess Image ----
def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).resize((224, 224))
    img = np.expand_dims(np.array(img).astype(np.float32) / 255.0, axis=0)
    return img

# ---- Route 1: Predict from Image ----
@app.route("/predict", methods=["POST"])
def predict_medicine():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400
    
    image_file = request.files['image']
    image_data = image_file.read()
    input_data = preprocess_image(image_data)

    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])[0]

    pred_idx = int(np.argmax(output_data))
    confidence = float(output_data[pred_idx])
    medicine_name = labels[pred_idx]

    return jsonify({
        "medicine": medicine_name,
        "confidence": confidence
    })

# ---- Route 2: Get Medicine Details ----
@app.route("/medicine/<name>", methods=["GET"])
def get_medicine_info(name):
    query = """
        SELECT m.name, d.form_name, c.category_name, m.used_for,
            ARRAY_AGG(DISTINCT i.indication_name) AS indications,
            ARRAY_AGG(DISTINCT s.effect_description) AS side_effects
        FROM medicines m
        JOIN dosage_forms d ON m.dosage_form_id = d.form_id
        JOIN categories c ON m.category_id = c.category_id
        LEFT JOIN medicine_indications mi ON m.medicine_id = mi.medicine_id
        LEFT JOIN indications i ON mi.indication_id = i.indication_id
        LEFT JOIN medicine_side_effects ms ON m.medicine_id = ms.medicine_id
        LEFT JOIN side_effects s ON ms.side_effect_id = s.side_effect_id
        WHERE LOWER(m.name) = LOWER(%s)
        GROUP BY m.name, d.form_name, c.category_name, m.used_for;
    """
    cur.execute(query, (name,))
    row = cur.fetchone()
    if not row:
        return jsonify({"error": "Medicine not found"}), 404

    return jsonify({
        "name": row[0],
        "dosage_form": row[1],
        "category": row[2],
        "used_for": row[3],
        "indications": row[4],
        "side_effects": row[5]
    })

# ---- Route 3: Search by Indication ----
@app.route("/search_by_indication", methods=["GET"])
def search_by_indication():
    indication = request.args.get("indication")
    if not indication:
        return jsonify({"error": "Indication not provided"}), 400

    query = """
        SELECT DISTINCT m.name
        FROM medicines m
        JOIN medicine_indications mi ON m.medicine_id = mi.medicine_id
        JOIN indications i ON mi.indication_id = i.indication_id
        WHERE LOWER(i.indication_name) LIKE LOWER(%s);
    """
    cur.execute(query, ('%' + indication + '%',))
    medicines = [row[0] for row in cur.fetchall()]

    return jsonify({
        "medicines_for_indication": medicines
    })

if __name__ == "__main__":
    app.run(debug=True)
