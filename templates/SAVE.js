// Enhanced Medicine Detection JavaScript
document.addEventListener('DOMContentLoaded', function() {
  // Elements
  const uploadArea = document.getElementById('uploadArea');
  const imageInput = document.getElementById('imageInput');
  const imageForm = document.getElementById('imageForm');
  const predictionResult = document.getElementById('predictionResult');
  const predictBtn = document.getElementById('predictBtn');
  
  // Set up the upload area
  if (uploadArea) {
    uploadArea.addEventListener('click', function() {
      imageInput.click();
    });
    
    // Set up drag and drop functionality
    setupDragAndDrop();
  }
  
  // File input change event
  if (imageInput) {
    imageInput.addEventListener('change', function() {
      if (this.files && this.files[0]) {
        const file = this.files[0];
        updateUploadAreaWithPreview(file);
      }
    });
  }
  
  // Form submission
  if (imageForm) {
    imageForm.addEventListener('submit', handleFormSubmit);
  }
  
  /**
   * Sets up drag and drop functionality for the upload area
   */
  function setupDragAndDrop() {
    // Prevent default drag behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      uploadArea.addEventListener(eventName, preventDefaults, false);
    });
    
    // Highlight drop area when item is dragged over it
    ['dragenter', 'dragover'].forEach(eventName => {
      uploadArea.addEventListener(eventName, highlightUploadArea, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
      uploadArea.addEventListener(eventName, unhighlightUploadArea, false);
    });
    
    // Handle dropped files
    uploadArea.addEventListener('drop', handleDrop, false);
  }
  
  /**
   * Prevents default behavior for drag and drop events
   */
  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }
  
  /**
   * Highlights the upload area during drag
   */
  function highlightUploadArea() {
    uploadArea.classList.add('highlight');
    uploadArea.style.backgroundColor = 'rgba(0, 119, 204, 0.15)';
    uploadArea.style.borderColor = '#00c2cb';
    uploadArea.style.transform = 'scale(1.02)';
  }
  
  /**
   * Removes highlight from the upload area
   */
  function unhighlightUploadArea() {
    uploadArea.classList.remove('highlight');
    uploadArea.style.backgroundColor = 'rgba(0, 119, 204, 0.05)';
    uploadArea.style.borderColor = '#0077cc';
    uploadArea.style.transform = 'scale(1)';
  }
  
  /**
   * Handles file drop events
   */
  function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;
    
    if (files && files[0]) {
      imageInput.files = files;
      updateUploadAreaWithPreview(files[0]);
    }
  }
  
  /**
   * Updates the upload area with a preview of the selected file
   */
  function updateUploadAreaWithPreview(file) {
    // Validate file is an image
    if (!file.type.match('image.*')) {
      showErrorMessage('Please select an image file (JPEG, PNG, etc.)');
      return;
    }
    
    const reader = new FileReader();
    
    reader.onload = function(e) {
      uploadArea.innerHTML = `
        <div class="preview-container">
          <img src="${e.target.result}" alt="Medicine preview" class="preview-image" style="max-height: 200px; max-width: 100%; border-radius: 8px; margin-bottom: 15px;">
          <h3>Ready to analyze</h3>
          <p>${file.name}</p>
        </div>
      `;
    };
    
    reader.readAsDataURL(file);
  }
  
  /**
   * Displays an error message
   */
  function showErrorMessage(message) {
    uploadArea.innerHTML = `
      <div class="upload-icon" style="color: #ff6b6b;">
        <i class="fas fa-exclamation-circle"></i>
      </div>
      <h3 style="color: #ff6b6b;">Error</h3>
      <p>${message}</p>
      <p style="margin-top: 15px;">Click to try again</p>
    `;
  }
  
  /**
   * Handles form submission for medicine prediction
   */
  async function handleFormSubmit(e) {
    e.preventDefault();
    
    // Check if file is selected
    if (!imageInput.files || !imageInput.files[0]) {
      alert('Please select an image first');
      return;
    }
    
    // Update button state
    predictBtn.disabled = true;
    predictBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Analyzing...';
    
    // Show loading indicator
    predictionResult.style.display = 'block';
    predictionResult.innerHTML = `
      <div class="result-header">
        <h3>Analyzing Your Medicine</h3>
        <p>Our AI is processing your image. This will take just a moment...</p>
      </div>
      <div class="loading">
        <div></div><div></div><div></div><div></div>
      </div>
    `;
    
    try {
      // Simulate API call
      const result = await simulatePredictionAPI();
      displayPredictionResult(result);
    } catch (error) {
      predictionResult.innerHTML = `
        <div class="result-header" style="color: #ff6b6b;">
          <i class="fas fa-exclamation-triangle" style="font-size: 3rem; margin-bottom: 1rem;"></i>
          <h3>Analysis Error</h3>
          <p>${error.message || 'There was a problem analyzing your image. Please try again.'}</p>
        </div>
      `;
    } finally {
      // Reset button state
      predictBtn.disabled = false;
      predictBtn.innerHTML = '<i class="fas fa-search"></i> Analyze Medicine';
    }
  }
  
  /**
   * Simulates an API call to predict medicine from an image
   * @returns {Promise} Resolves with the prediction result
   */
  function simulatePredictionAPI() {
    return new Promise((resolve) => {
      setTimeout(() => {
        // Simulate medicine detection with more detailed data
        const medicines = [
          { 
            name: 'Aspirin', 
            dosage: '325mg',
            category: 'Anti-inflammatory',
            description: 'Common pain reliever and fever reducer'
          },
          { 
            name: 'Paracetamol', 
            dosage: '500mg',
            category: 'Analgesic',
            description: 'Treats mild to moderate pain and reduces fever'
          },
          { 
            name: 'Amoxicillin', 
            dosage: '250mg',
            category: 'Antibiotic',
            description: 'Treats bacterial infections'
          },
          { 
            name: 'Ibuprofen', 
            dosage: '400mg',
            category: 'NSAID',
            description: 'Reduces pain, inflammation, and fever'
          },
          { 
            name: 'Metformin', 
            dosage: '500mg',
            category: 'Antidiabetic',
            description: 'Controls blood sugar levels in type 2 diabetes'
          }
        ];
        
        const randomMedicine = medicines[Math.floor(Math.random() * medicines.length)];
        const confidence = (Math.random() * 0.3 + 0.7).toFixed(2); // Random confidence between 70-100%
        
        resolve({
          medicine: randomMedicine,
          confidence: confidence
        });
      }, 2500);
    });
  }
  
  /**
   * Displays the prediction result in the UI
   * @param {Object} result - The prediction result
   */
  function displayPredictionResult(result) {
    const confidencePercentage = (result.confidence * 100).toFixed(1);
    const medicine = result.medicine;
    
    // Create the HTML for the prediction result
    const resultHTML = `
      <div class="result-header">
        <i class="fas fa-check-circle" style="font-size: 3rem; margin-bottom: 1rem; color: #4CAF50;"></i>
        <h3>Medicine Identified</h3>
        <p>Our AI has analyzed your image with high confidence</p>
      </div>
      
      <div class="result-content">
        <div class="result-item">
          <h4>Medicine Name</h4>
          <p>${medicine.name}</p>
        </div>
        
        <div class="result-item">
          <h4>Dosage</h4>
          <p>${medicine.dosage}</p>
        </div>
        
        <div class="result-item">
          <h4>Category</h4>
          <p>${medicine.category}</p>
        </div>
      </div>
      
      <div style="margin-top: 2rem;">
        <h4>Confidence Level</h4>
        <div class="confidence-bar">
          <div class="confidence-level" style="width: ${confidencePercentage}%"></div>
        </div>
        <p style="text-align: right; margin-top: 0.5rem; font-size: 0.9rem;">${confidencePercentage}%</p>
      </div>
      </div>
      
      <div style="margin-top: 2rem;">
        <h4>Description</h4>
        <p>${medicine.description}</p>
      </div>
    `;

    predictionResult.innerHTML = resultHTML;
  }

});
