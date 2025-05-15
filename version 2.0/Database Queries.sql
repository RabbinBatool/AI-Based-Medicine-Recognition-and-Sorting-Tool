-- 1. Dosage Forms Table
CREATE TABLE dosage_forms (
    form_id SERIAL PRIMARY KEY,
    form_name TEXT NOT NULL UNIQUE
);
drop table dosage_forms cascade;

-- 2. Categories Table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);
drop table categories cascade;

-- 3. Medicines Table
CREATE TABLE medicines (
    medicine_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    dosage_form_id INT REFERENCES dosage_forms(form_id) ON DELETE SET NULL,
    category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
    used_for TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
drop table medicines cascade;

-- 4. Indications Table
CREATE TABLE indications (
    indication_id SERIAL PRIMARY KEY,
    indication_name TEXT NOT NULL UNIQUE
);
drop table indications cascade;

-- 5. Medicine-Indication (Many-to-Many)
CREATE TABLE medicine_indications (
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    indication_id INT REFERENCES indications(indication_id) ON DELETE CASCADE,
    PRIMARY KEY (medicine_id, indication_id)
);
drop table medicine_indications cascade;

-- 6. Side Effects Table
CREATE TABLE side_effects (
    side_effect_id SERIAL PRIMARY KEY,
    effect_description TEXT NOT NULL UNIQUE
);
drop table side_effects cascade;

-- 7. Medicine-SideEffect (Many-to-Many)
CREATE TABLE medicine_side_effects (
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    side_effect_id INT REFERENCES side_effects(side_effect_id) ON DELETE CASCADE,
    PRIMARY KEY (medicine_id, side_effect_id)
);

drop table medicine_side_effects cascade;

-- 8. Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
drop table users;

-- 9. Predictions Table (for AI results)
CREATE TABLE predictions (
    prediction_id SERIAL PRIMARY KEY,
    medicine_id INT REFERENCES medicines(medicine_id),
    confidence FLOAT CHECK (confidence >= 0 AND confidence <= 1),
    image_path TEXT,
    predicted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT REFERENCES users(user_id)
);
drop table predictions;

-- Inserting Dosage Forms
INSERT INTO dosage_forms (form_name)
SELECT DISTINCT form_name
FROM (
    VALUES
    ('Gel'), ('Tablet'), ('Capsule'), ('Syrup'), ('Cream'),
    ('Ointment'), ('Injection'), ('Inhaler')
) AS t(form_name)
WHERE NOT EXISTS (SELECT 1 FROM dosage_forms WHERE form_name = t.form_name);

-- Inserting Categories
INSERT INTO categories (category_name)
SELECT DISTINCT category_name
FROM (
    VALUES
    ('NSAID'), ('Antihistamine'), ('Antibiotic'),
    ('Corticosteroid with antibiotic'), ('Cough suppressant'),
    ('Corticosteroid'), ('Iron supplement'), ('Antidiabetic'),
    ('Beta-blocker'), ('Immunotherapy'), ('Analgesic/Antipyretic'),
    ('Bronchodilator'), ('Multivitamin'), ('Topical decongestant'),
    ('H2 blocker'), ('Statin'), ('SSRI'), ('Benzodiazepine'),
    ('PDE5 inhibitor'), ('Proton pump inhibitor'), ('Sedative'),
    ('Thyroid hormone'), ('Anticonvulsant'), ('Antiviral'),
    ('Atypical antipsychotic'), ('Biologic'),
    ('GLP-1 receptor agonist'), ('SGLT2 inhibitor'), ('Anticoagulant'),
    ('ARNi'), ('DPP-4 inhibitor'), ('Monoclonal antibody'),
    ('Kinase inhibitor'), ('VEGF inhibitor'), ('Atypical antidepressant'),
    ('IL-17A inhibitor'), ('IL-4/IL-13 inhibitor'), ('ACE Inhibitor'),
    ('Biguanide'), ('ARB'), ('Diuretic'), ('Loop Diuretic'),
    ('Leukotriene Modifier'), ('SNRI'), ('Opioid'), ('Fluoroquinolone'),
    ('Alpha/Beta Blocker'), ('Antiplatelet'), ('Muscle Relaxant'), ('Antiemetic')
) AS t(category_name)
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE category_name = t.category_name);

-- Inserting Medicines
INSERT INTO medicines (name, dosage_form_id, category_id, used_for)
SELECT DISTINCT
    medicine_name,
    (SELECT form_id FROM dosage_forms WHERE form_name = t.dosage_form),
    (SELECT category_id FROM categories WHERE category_name = t.category),
    used_for
FROM (
    VALUES
    ('Aleve Gel', 'Gel', 'NSAID', 'Topical pain relief'),
    ('Aleve', 'Tablet', 'NSAID', 'Pain and inflammation relief'),
    ('Allegra', 'Tablet', 'Antihistamine', 'Allergy relief'),
    ('amoxicillin', 'Capsule', 'Antibiotic', 'Bacterial infection treatment'),
    ('amoxicillin Syrup', 'Syrup', 'Antibiotic', 'Bacterial infection treatment'),  
    ('amoxicillin Tablet', 'Tablet', 'Antibiotic', 'Bacterial infection treatment'),  
    ('Augmentin Syrup', 'Syrup', 'Antibiotic', 'Broad-spectrum bacterial infection treatment'), 
    ('Augmentin Tablet', 'Tablet', 'Antibiotic', 'Broad-spectrum bacterial infection treatment'), 
    ('betnovate-N', 'Cream', 'Corticosteroid with antibiotic', 'Inflammatory skin conditions with bacterial infection'),
    ('Coferb Syrup', 'Syrup', 'Cough suppressant', 'Cough relief'),
    ('Coferb Tablet', 'Tablet', 'Cough suppressant', 'Cough relief'), 
    ('Dermex', 'Ointment', 'Corticosteroid', 'Inflammatory skin conditions'),
    ('Doxycycline', 'Capsule', 'Antibiotic', 'Broad-spectrum bacterial infection treatment'),
    ('Ferosoft Injection', 'Injection', 'Iron supplement', 'Iron deficiency treatment'), 
    ('Ferosoft Syrup', 'Syrup', 'Iron supplement', 'Iron deficiency treatment'), 
    ('Ferosoft Tablet', 'Tablet', 'Iron supplement', 'Iron deficiency treatment'), 
    ('Flagyl Injection', 'Injection', 'Antibiotic', 'Anaerobic infection treatment'), 
    ('Flagyl Syrup', 'Syrup', 'Antibiotic', 'Anaerobic infection treatment'),  
    ('Flagyl Tablet', 'Tablet', 'Antibiotic', 'Anaerobic infection treatment'),  
    ('Glucophage', 'Tablet', 'Antidiabetic', 'Type 2 diabetes management'),
    ('Lopressor', 'Tablet', 'Beta-blocker', 'Cardiovascular conditions'),
    ('Opdivo', 'Injection', 'Immunotherapy', 'Cancer treatment'),
    ('Panadol Syrup', 'Syrup', 'Analgesic/Antipyretic', 'Pain and fever relief'),
    ('Panadol Tablet', 'Tablet', 'Analgesic/Antipyretic', 'Pain and fever relief'), 
    ('Pulmonol Syrup', 'Syrup', 'Bronchodilator', 'Respiratory relief'),
    ('Shevit', 'Tablet', 'Multivitamin', 'Vitamin supplementation'),
    ('Vaporub', 'Gel', 'Topical decongestant', 'Cold and cough relief'),
    ('Ventolin', 'Inhaler', 'Bronchodilator', 'Asthma management'),
    ('Votral Emulgel', 'Gel', 'NSAID', 'Topical pain and inflammation relief'),
    ('Zantac', 'Tablet', 'H2 blocker', 'Acid reflux treatment'),
    ('Lipitor', 'Tablet', 'Statin', 'Cholesterol management'),
    ('Prozac', 'Capsule', 'SSRI', 'Depression treatment'),
    ('Xanax', 'Tablet', 'Benzodiazepine', 'Anxiety treatment'),
    ('Advil Tablet', 'Tablet', 'NSAID', 'Pain and inflammation relief'), 
    ('Advil Gel', 'Gel', 'NSAID', 'Topical pain relief'),
    ('Benadryl Tablet', 'Tablet', 'Antihistamine', 'Allergy relief'),
    ('Benadryl Syrup', 'Syrup', 'Antihistamine', 'Allergy relief'),  
    ('Claritin', 'Tablet', 'Antihistamine', 'Allergy relief'),
    ('Cialis', 'Tablet', 'PDE5 inhibitor', 'Erectile dysfunction treatment'),
    ('Nexium', 'Capsule', 'Proton pump inhibitor', 'Acid reflux treatment'),
    ('Ambien', 'Tablet', 'Sedative', 'Sleep aid'),
    ('Synthroid', 'Tablet', 'Thyroid hormone', 'Thyroid hormone replacement'),
    ('Crestor', 'Tablet', 'Statin', 'Cholesterol management'),
    ('Lyrica', 'Capsule', 'Anticonvulsant', 'Nerve pain treatment'),
    ('Tamiflu Capsule', 'Capsule', 'Antiviral', 'Influenza treatment'), 
    ('Tamiflu Syrup', 'Syrup', 'Antiviral', 'Influenza treatment'),  
    ('Abilify Tablet', 'Tablet', 'Atypical antipsychotic', 'Mental health treatment'), 
    ('Abilify Solution', 'Solution', 'Atypical antipsychotic', 'Mental health treatment'), 
    ('Humira', 'Injection', 'Biologic', 'Autoimmune disease treatment'),
    ('Ozempic', 'Injection', 'GLP-1 receptor agonist', 'Diabetes management'),
    ('Jardiance', 'Tablet', 'SGLT2 inhibitor', 'Diabetes management'),
    ('Eliquis', 'Tablet', 'Anticoagulant', 'Blood clot prevention'),
    ('Entresto', 'Tablet', 'ARNi', 'Heart failure treatment'),
    ('Januvia', 'Tablet', 'DPP-4 inhibitor', 'Diabetes management'),
    ('Stelara', 'Injection', 'Biologic', 'Autoimmune disease treatment'),
    ('Trulicity', 'Injection', 'GLP-1 receptor agonist', 'Diabetes management'),
    ('Rituxan', 'Injection', 'Monoclonal antibody', 'Cancer and autoimmune treatment'),
    ('Imbruvica', 'Capsule', 'Kinase inhibitor', 'Cancer treatment'),
    ('Eylea', 'Injection', 'VEGF inhibitor', 'Eye disease treatment'),
    ('Seroquel', 'Tablet', 'Atypical antipsychotic', 'Mental health treatment'),
    ('Latuda', 'Tablet', 'Atypical antipsychotic', 'Mental health treatment'),
    ('Trintellix', 'Tablet', 'Atypical antidepressant', 'Depression treatment'),
    ('Cosentyx', 'Injection', 'IL-17A inhibitor', 'Autoimmune disease treatment'),
    ('Dupixent', 'Injection', 'IL-4/IL-13 inhibitor', 'Inflammatory disease treatment'),
    ('Keytruda', 'Injection', 'Immunotherapy', 'Cancer treatment'),
    ('Lisinopril','Tablet','ACE Inhibitor','Hypertension'),
    ('Atorvastatin','Tablet','Statin','Cholesterol'),
    ('Metformin','Tablet','Biguanide','Diabetes'),
    ('Sertraline','Tablet','SSRI','Depression'),
    ('Ibuprofen','Tablet','NSAID','Pain'),
    ('Omeprazole','Capsule','Proton Pump Inhibitor','Acid reflux'),
    ('Levothyroxine','Tablet','Thyroid Hormone','Hypothyroidism'),
    ('Amlodipine','Tablet','Calcium Channel Blocker','Hypertension'),
    ('Albuterol','Inhaler','Beta-2 Agonist','Asthma'),
    ('Simvastatin','Tablet','Statin','Cholesterol'),
    ('Metoprolol','Tablet','Beta Blocker','Hypertension'),
    ('Fluoxetine','Capsule','SSRI','Depression'),
    ('Losartan','Tablet','ARB','Hypertension'),
    ('Azithromycin','Tablet','Antibiotic','Bacterial infections'),
    ('Hydrochlorothiazide','Tablet','Diuretic','Hypertension'),
    ('Gabapentin','Capsule','Anticonvulsant','Seizures'),
    ('Warfarin','Tablet','Anticoagulant','Blood clots'),
    ('Pantoprazole','Tablet','Proton Pump Inhibitor','Acid reflux'),
    ('Prednisone','Tablet','Corticosteroid','Inflammation'),
    ('Furosemide','Tablet','Loop Diuretic','Edema'),
    ('Citalopram','Tablet','SSRI','Depression'),
    ('Montelukast','Tablet','Leukotriene Modifier','Asthma'),
    ('Venlafaxine','Capsule','SNRI','Depression'),
    ('Rosuvastatin','Tablet','Statin','Cholesterol'),
    ('Tramadol','Tablet','Opioid','Pain'),
    ('Escitalopram','Tablet','SSRI','Depression'),
    ('Ciprofloxacin','Tablet','Fluoroquinolone','Bacterial infections'),
    ('Duloxetine','Capsule','SNRI','Depression'),
    ('Lorazepam','Tablet','Benzodiazepine','Anxiety'),
    ('Carvedilol','Tablet','Alpha/Beta Blocker','Heart failure'),
    ('Clonazepam','Tablet','Benzodiazepine','Seizures'),
    ('Cetirizine','Tablet','Antihistamine','Allergies'),
    ('Levofloxacin','Tablet','Fluoroquinolone','Bacterial infections'),
    ('Atenolol','Tablet','Beta Blocker','Hypertension'),
    ('Famotidine','Tablet','H2 Blocker','Acid reflux'),
    ('Bupropion','Tablet','Atypical Antidepressant','Depression'),
    ('Clopidogrel','Tablet','Antiplatelet','Blood clots'),
    ('Loratadine','Tablet','Antihistamine','Allergies'),
    ('Pregabalin','Capsule','Anticonvulsant','Neuropathic pain'),
    ('Tadalafil','Tablet','PDE5 Inhibitor','Erectile dysfunction'),
    ('Pravastatin','Tablet','Statin','Cholesterol'),
    ('Valacyclovir','Tablet','Antiviral','Viral infections'),
    ('Metronidazole','Tablet','Antibiotic','Bacterial infections'),
    ('Diazepam','Tablet','Benzodiazepine','Anxiety'),
    ('Propranolol','Tablet','Beta Blocker','Hypertension'),
    ('Ondansetron','Tablet','Antiemetic','Nausea'),
    ('Celecoxib','Capsule','NSAID','Pain'),
    ('Cyclobenzaprine','Tablet','Muscle Relaxant','Muscle spasms')
) AS t(medicine_name, dosage_form, category, used_for)
WHERE NOT EXISTS (SELECT 1 FROM medicines WHERE name = t.medicine_name);


-- Inserting Indications
INSERT INTO indications (indication_name)
SELECT DISTINCT indication
FROM (
    VALUES
    ('muscle pain'), ('joint pain'), ('arthritis'), ('sprains'), ('strains'),
    ('headaches'), ('toothaches'), ('menstrual cramps'), ('muscle aches'), ('fever'),
    ('seasonal allergies'), ('hay fever'), ('hives'), ('itching'), ('runny nose'),
    ('watery eyes'), ('respiratory infections'), ('ear infections'),
    ('urinary tract infections'), ('skin infections'), ('dental infections'),
    ('sinusitis'), ('pneumonia'), ('dermatitis'), ('eczema'), ('psoriasis'),
    ('insect bites'), ('infected skin lesions'), ('dry cough'), ('irritating cough'),
    ('bronchitis'), ('upper respiratory infections'), ('acne'), ('malaria prevention'),
    ('Lyme disease'), ('iron deficiency anemia'), ('pregnancy'), ('blood loss'),
    ('malabsorption'), ('amoebic dysentery'), ('giardiasis'), ('trichomoniasis'),
    ('bacterial vaginosis'), ('H. pylori'), ('high blood sugar'), ('insulin resistance'),
    ('metabolic syndrome'), ('polycystic ovary syndrome'), ('hypertension'), ('angina'),
    ('heart failure'), ('post-heart attack'), ('arrhythmias'), ('melanoma'),
    ('lung cancer'), ('renal cell carcinoma'), ('Hodgkin lymphoma'),
    ('head and neck cancer'), ('cold/flu symptoms'), ('COPD'), ('asthma'),
    ('bronchospasm'), ('exercise-induced bronchospasm'), ('acid reflux'), ('GERD'),
    ('peptic ulcers'), ('gastritis'), ('high cholesterol'),
    ('atherosclerosis prevention'), ('cardiovascular disease risk reduction'),
    ('major depressive disorder'), ('obsessive-compulsive disorder'), ('panic disorder'),
    ('bulimia nervosa'), ('anxiety disorders'), ('social anxiety disorder'),
    ('erectile dysfunction'), ('benign prostatic hyperplasia'), ('insomnia'),
    ('difficulty falling asleep'), ('sleep maintenance'), ('hypothyroidism'),
    ('thyroid cancer'), ('goiter'), ('thyroiditis'), ('triglycerides'),
    ('diabetic neuropathy'), ('fibromyalgia'), ('post-herpetic neuralgia'),
    ('partial onset seizures'), ('influenza A and B treatment and prevention'),
    ('schizophrenia'), ('bipolar disorder'), ('autism'),
    ('autoimmune disease treatment'), ('type 2 diabetes'), ('weight management'),
    ('cardiovascular risk reduction'), ('chronic kidney disease'),
    ('prevention of stroke in atrial fibrillation'), ('treatment of DVT and PE'),
    ('glycemic control'), ('non-Hodgkins lymphoma'),
    ('chronic lymphocytic leukemia'), ('WaldenstruFFFDms macroglobulinemia'),
    ('age-related macular degeneration'), ('diabetic macular edema'),
    ('diabetic retinopathy'), ('bipolar depression'), ('treatment-resistant depression'),
    ('non-radiographic axial spondyloarthritis'),
    ('atopic dermatitis'), ('chronic rhinosinusitis with nasal polyps'),
    ('non-small cell lung cancer'), ('edema'), ('kidney stones'),
    ('seizures'), ('neuropathic pain'), ('restless leg syndrome'), ('hot flashes'),
    ('acute coronary syndrome'), ('peripheral arterial disease'), ('stroke prevention'),
    ('pulmonary arterial hypertension'), ('viral infections')
) AS t(indication)
WHERE NOT EXISTS (SELECT 1 FROM indications WHERE indication_name = t.indication);


select * from side_effects;
-- Inserting Side Effects
INSERT INTO side_effects (effect_description)
SELECT DISTINCT effect
FROM (
    VALUES
    ('skin irritation'), ('rash'), ('allergic reactions'), ('stomach pain'),
    ('heartburn'), ('nausea'), ('dizziness'), ('drowsiness'), ('headache'),
    ('dry mouth'), ('fatigue'), ('diarrhea'), ('stomach upset'), ('vomiting'),
    ('liver enzyme elevation'), ('yeast infections'), ('skin thinning'), ('striae'),
    ('local irritation'), ('burning sensation'), ('secondary infection'),
    ('constipation'), ('photosensitivity'), ('esophageal irritation'),
    ('pain at injection site'), ('dark stools'), ('metallic taste'),
    ('peripheral neuropathy'), ('loss of appetite'), ('abdominal discomfort'),
    ('vitamin B12 deficiency'), ('bradycardia'), ('cold extremities'),
    ('sleep disturbances'), ('itching'), ('immune-related adverse events'),
    ('rare: allergic reactions'), ('rare: liver damage (with overdose)'),
    ('tremor'), ('nervousness'), ('rapid heartbeat'), ('upset stomach'),
    ('unusual taste'), ('if applied to broken skin'), ('blurred vision'),
    ('urinary retention'), ('indigestion'), ('back pain'), ('muscle aches'),
    ('flushing'), ('abdominal pain'), ('daytime drowsiness'),
    ('complex sleep behaviors'), ('memory problems'), ('weight loss'),
    ('increased appetite'), ('weakness'), ('joint pain'), ('weight gain'),
    ('ataxia'), ('psychiatric effects (rare)'), ('akathisia'),
    ('injection site reactions'), ('increased infection risk'), ('sinusitis'),
    ('decreased appetite'), ('infusion reactions'), ('cardiac events'),
    ('kidney problems'), ('musculoskeletal pain'), ('eye pain'),
    ('vitreous floaters'), ('cataract'), ('retinal detachment'),
    ('increased intraocular pressure'), ('sedation'), ('somnolence'),
    ('parkinsonism'), ('upper respiratory infections'), ('behavior changes'),
    ('neuropsychiatric events'), ('conjunctivitis'), ('oral herpes'),
    ('keratitis'), ('pruritus'), ('immune-mediated adverse reactions'),
    ('dry cough'), ('hypotension'), ('fluid retention'), ('gastrointestinal irritation'),
    ('bleeding'), ('bruising'), ('hematoma'), ('purple toe syndrome'),
    ('gout'), ('ototoxicity'), ('increased sweating'), ('tendon damage'),
    ('QT prolongation'), ('peripheral edema'), ('dependence'),
    ('anterograde amnesia')
) AS t(effect)
WHERE NOT EXISTS (SELECT 1 FROM side_effects WHERE effect_description = t.effect);

select * from indications;


-- 1. Insert into dosage_forms
INSERT INTO dosage_forms (form_name) VALUES
('Tablet'),
('Capsule'),
('Syrup'),
('Injection'),
('Cream'),
('Ointment'),
('Drops');

-- 2. Insert into categories
INSERT INTO categories (category_name) VALUES
('Analgesics'),
('Antibiotics'),
('Antihistamines'),
('Antacids'),
('Antifungals'),
('Antivirals'),
('Vitamins');

-- 3. Insert into medicines
INSERT INTO medicines (name, dosage_form_id, category_id, used_for)
SELECT 'Paracetamol', form_id, category_id, 'Pain relief, fever'
FROM dosage_forms, categories
WHERE form_name = 'Tablet' AND category_name = 'Analgesics'
UNION ALL
SELECT 'Amoxicillin', form_id, category_id, 'Bacterial infections'
FROM dosage_forms, categories
WHERE form_name = 'Capsule' AND category_name = 'Antibiotics'
UNION ALL
SELECT 'Fluconazole', form_id, category_id, 'Fungal infections'
FROM dosage_forms, categories
WHERE form_name = 'Tablet' AND category_name = 'Antifungals'
UNION ALL
SELECT 'Acyclovir', form_id, category_id, 'Herpes infections'
FROM dosage_forms, categories
WHERE form_name = 'Cream' AND category_name = 'Antivirals'
UNION ALL
SELECT 'Vitamin D3', form_id, category_id, 'Vitamin D deficiency'
FROM dosage_forms, categories
WHERE form_name = 'Capsule' AND category_name = 'Vitamins';

-- 4. Insert into indications
INSERT INTO indications (indication_name) VALUES
('Pain'),
('Fever'),
('Bacterial Infection'),
('Allergy'),
('Heartburn'),
('Acid Reflux'),
('Fungal Infection'),
('Herpes Simplex'),
('Vitamin Deficiency'),
('Inflammation');

-- 5. Insert into medicine_indications (linking medicines to indications)
INSERT INTO medicine_indications (medicine_id, indication_id)
SELECT m.medicine_id, i.indication_id
FROM medicines m
JOIN indications i ON i.indication_name = 'Bacterial Infection'
WHERE m.name = 'Amoxicillin'
UNION ALL
SELECT m.medicine_id, i.indication_id
FROM medicines m
JOIN indications i ON i.indication_name = 'Allergy'
WHERE m.name = 'Amoxicillin'
UNION ALL
SELECT m.medicine_id, i.indication_id
FROM medicines m
JOIN indications i ON i.indication_name = 'Heartburn'
WHERE m.name = 'Amoxicillin'
UNION ALL
SELECT m.medicine_id, i.indication_id
FROM medicines m
JOIN indications i ON i.indication_name = 'Acid Reflux'
WHERE m.name = 'Amoxicillin'
UNION ALL
SELECT m.medicine_id, i.indication_id
FROM medicines m
JOIN indications i ON i.indication_name = 'Fungal Infection'
WHERE m.name = 'Fluconazole';


-- 6. Insert into side_effects
INSERT INTO side_effects (effect_description) VALUES
('Nausea'),
('Diarrhea'),
('Drowsiness'),
('Headache'),
('Skin rash'),
('Dizziness'),
('Stomach pain');

-- 7. Insert into medicine_side_effects (linking medicines to side effects)
INSERT INTO medicine_side_effects (medicine_id, side_effect_id)
SELECT m.medicine_id, s.side_effect_id
FROM medicines m
JOIN side_effects s ON s.effect_description = 'Nausea'
WHERE m.name = 'Paracetamol'
UNION ALL
SELECT m.medicine_id, s.side_effect_id
FROM medicines m
JOIN side_effects s ON s.effect_description = 'Diarrhea'
WHERE m.name = 'Amoxicillin'
UNION ALL
SELECT m.medicine_id, s.side_effect_id
FROM medicines m
JOIN side_effects s ON s.effect_description = 'Drowsiness'
WHERE m.name = 'Amoxicillin'
UNION ALL
SELECT m.medicine_id, s.side_effect_id
FROM medicines m
JOIN side_effects s ON s.effect_description = 'Headache'
WHERE m.name = 'Amoxicillin'
UNION ALL
SELECT m.medicine_id, s.side_effect_id
FROM medicines m
JOIN side_effects s ON s.effect_description = 'Skin rash'
WHERE m.name = 'Fluconazole'
UNION ALL
SELECT m.medicine_id, s.side_effect_id
FROM medicines m
JOIN side_effects s ON s.effect_description = 'Nausea'
WHERE m.name = 'Amoxicillin';



















