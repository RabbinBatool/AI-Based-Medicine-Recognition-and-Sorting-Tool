---1. medicine
CREATE TABLE medicines (
    medicine_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    dosage_form_id INT NOT NULL REFERENCES dosage_forms(form_id) ON DELETE SET NULL,
    category_id INT NOT NULL REFERENCES categories(category_id) ON DELETE SET NULL,
    used_for TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---2. dosage_forms
CREATE TABLE dosage_forms (
    form_id SERIAL PRIMARY KEY,
    form_name TEXT NOT NULL UNIQUE
);

---3. categories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

---4. indications
CREATE TABLE indications (
    indication_id SERIAL PRIMARY KEY,
    indication_name TEXT NOT NULL UNIQUE
);

---5. medicine_indications
CREATE TABLE medicine_indications (
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    indication_id INT REFERENCES indications(indication_id) ON DELETE CASCADE,
    PRIMARY KEY (medicine_id, indication_id)
);

---6. side_effects
CREATE TABLE side_effects (
    side_effect_id SERIAL PRIMARY KEY,
    effect_description TEXT NOT NULL UNIQUE
);

---7. medicine_side_effects
CREATE TABLE medicine_side_effects (
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    side_effect_id INT REFERENCES side_effects(side_effect_id) ON DELETE CASCADE,
    PRIMARY KEY (medicine_id, side_effect_id)
);

---8. users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---9. predictions
CREATE TABLE predictions (
    prediction_id SERIAL PRIMARY KEY,
    medicine_id INT REFERENCES medicines(medicine_id),
    confidence FLOAT CHECK (confidence >= 0 AND confidence <= 1),
    image_path TEXT,
    predicted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	user_id INT REFERENCES users(user_id);
);
