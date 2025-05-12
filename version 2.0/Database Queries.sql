-- 1. Dosage Forms Table
CREATE TABLE dosage_forms (
    form_id SERIAL PRIMARY KEY,
    form_name TEXT NOT NULL UNIQUE
);

-- 2. Categories Table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

-- 3. Medicines Table
CREATE TABLE medicines (
    medicine_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    dosage_form_id INT REFERENCES dosage_forms(form_id) ON DELETE SET NULL,
    category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
    used_for TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Indications Table
CREATE TABLE indications (
    indication_id SERIAL PRIMARY KEY,
    indication_name TEXT NOT NULL UNIQUE
);

-- 5. Medicine-Indication (Many-to-Many)
CREATE TABLE medicine_indications (
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    indication_id INT REFERENCES indications(indication_id) ON DELETE CASCADE,
    PRIMARY KEY (medicine_id, indication_id)
);

-- 6. Side Effects Table
CREATE TABLE side_effects (
    side_effect_id SERIAL PRIMARY KEY,
    effect_description TEXT NOT NULL UNIQUE
);

-- 7. Medicine-SideEffect (Many-to-Many)
CREATE TABLE medicine_side_effects (
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    side_effect_id INT REFERENCES side_effects(side_effect_id) ON DELETE CASCADE,
    PRIMARY KEY (medicine_id, side_effect_id)
);

-- 8. Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Predictions Table (for AI results)
CREATE TABLE predictions (
    prediction_id SERIAL PRIMARY KEY,
    medicine_id INT REFERENCES medicines(medicine_id),
    confidence FLOAT CHECK (confidence >= 0 AND confidence <= 1),
    image_path TEXT,
    predicted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT REFERENCES users(user_id)
);

