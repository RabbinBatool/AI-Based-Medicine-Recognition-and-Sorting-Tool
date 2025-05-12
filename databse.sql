CREATE TABLE Manufacturer (
    manufacturer_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255),
    contact_info TEXT
);


CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE ActiveIngredient (
    ingredient_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Create table for Medicines
CREATE TABLE Medicine (
    medicine_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50), -- Tablet, Syrup, Capsule, etc.
    purpose VARCHAR(255), -- e.g., Fever reducer, Antibiotic
    dosage_strength VARCHAR(100), -- e.g., 500mg
    indicator TEXT, -- For which condition it is used
    classification VARCHAR(255), -- Category/Classification
    expiry_date DATE,
    manufacturer_id INT,
    category_id INT,
    FOREIGN KEY (manufacturer_id) REFERENCES Manufacturer(manufacturer_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE MedicineIngredient (
    medicine_id INT,
    ingredient_id INT,
    PRIMARY KEY (medicine_id, ingredient_id),
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ActiveIngredient(ingredient_id) ON DELETE CASCADE
);

-- Create table for Side Effects
CREATE TABLE SideEffect (
    side_effect_id SERIAL PRIMARY KEY,
    description TEXT NOT NULL
);

-- Create table for linking Medicines with Side Effects (Many-to-Many)
CREATE TABLE MedicineSideEffect (
    medicine_id INT,
    side_effect_id INT,
    PRIMARY KEY (medicine_id, side_effect_id),
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE,
    FOREIGN KEY (side_effect_id) REFERENCES SideEffect(side_effect_id) ON DELETE CASCADE
);


CREATE TABLE MedicineInteraction (
    interaction_id SERIAL PRIMARY KEY,
    medicine_id INT NOT NULL,
    interacting_medicine_id INT NOT NULL,
    interaction_description TEXT,
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE,
    FOREIGN KEY (interacting_medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE
);

-- Create table for Users
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(50) DEFAULT 'user', -- 'user' or 'admin'
    email VARCHAR(255) UNIQUE
);


CREATE TABLE RecognitionFeedback (
    feedback_id SERIAL PRIMARY KEY,
    user_id INT,
    medicine_id INT,
    feedback_text TEXT,
    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id)
);
