document.addEventListener('DOMContentLoaded', function() {
  // Elements
  const medicineNameInput = document.getElementById('medicineName');
  const searchBtn = document.getElementById('searchBtn');
  const medicineInfo = document.getElementById('medicineInfo');
  const loadingIndicator = document.getElementById('loadingIndicator');
  const noResults = document.getElementById('noResults');
  const searchHistory = document.getElementById('searchHistory');
  
  // Initialize search history from localStorage
  let history = JSON.parse(localStorage.getItem('medicineSearchHistory')) || [];
  renderSearchHistory();
  
  // Event listeners
  searchBtn.addEventListener('click', searchMedicine);
  medicineNameInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      searchMedicine();
    }
  });
  
  // Mobile menu toggle
  const hamburger = document.querySelector('.hamburger');
  const navLinks = document.querySelector('.nav-links');
  
  if (hamburger) {
    hamburger.addEventListener('click', function() {
      hamburger.classList.toggle('active');
      navLinks.classList.toggle('active');
    });
  }
  
  /**
   * Search for medicine details
   */
  function searchMedicine() {
    const name = medicineNameInput.value.trim();
    if (!name) {
      showInputError(medicineNameInput, 'Please enter a medicine name');
      return;
    }
    
    // Show loading indicator
    medicineInfo.innerHTML = '';
    medicineInfo.classList.remove('visible');
    loadingIndicator.style.display = 'flex';
    noResults.style.display = 'none';
    
    // API request
    fetch(`/medicine/${encodeURIComponent(name)}`)
      .then(response => {
        if (!response.ok) {
          throw new Error('Medicine not found');
        }
        return response.json();
      })
      .then(data => {
        // Hide loading indicator
        loadingIndicator.style.display = 'none';
        
        // Add to search history
        addToSearchHistory(data.name);
        
        // Display medicine info
        renderMedicineInfo(data);
      })
      .catch(error => {
        console.error('Error:', error);
        loadingIndicator.style.display = 'none';
        noResults.style.display = 'flex';
      });
  }
  
  /**
   * Display medicine information in a formatted way
   */
  function renderMedicineInfo(data) {
    const html = `
      <div class="medicine-header">
        <h2>${data.name}</h2>
        <div class="medicine-category">${data.category}</div>
        <button class="print-btn" onclick="window.print()">
          <i class="fas fa-print"></i> Print
        </button>
      </div>
      <div class="medicine-body">
        <div class="info-row">
          <div class="info-label">Dosage Form:</div>
          <div class="info-value">${data.dosage_form}</div>
        </div>
        <div class="info-row">
          <div class="info-label">Used For:</div>
          <div class="info-value">${data.used_for}</div>
        </div>
        <div class="info-row">
          <div class="info-label">Indications:</div>
          <div class="info-value">
            ${data.indications.map(indication => `<span class="info-tag">${indication}</span>`).join('')}
          </div>
        </div>
        <div class="info-row">
          <div class="info-label">Side Effects:</div>
          <div class="info-value">
            ${data.side_effects.map(effect => `<span class="info-tag">${effect}</span>`).join('')}
          </div>
        </div>
        
        <div class="warning-box">
          <h4><i class="fas fa-exclamation-triangle"></i> Important Notice</h4>
          <p>This information is for reference only. Always consult with a healthcare professional before taking any medication.</p>
        </div>
      </div>
    `;
    
    medicineInfo.innerHTML = html;
    
    // Animate the appearance
    setTimeout(() => {
      medicineInfo.classList.add('visible');
    }, 100);
  }
  
  /**
   * Add medicine to search history
   */
  function addToSearchHistory(medicineName) {
    // Remove if already exists
    history = history.filter(item => item !== medicineName);
    
    // Add to beginning of array
    history.unshift(medicineName);
    
    // Keep only the most recent 5 searches
    if (history.length > 5) {
      history = history.slice(0, 5);
    }
    
    // Save to localStorage
    localStorage.setItem('medicineSearchHistory', JSON.stringify(history));
    
    // Update UI
    renderSearchHistory();
  }
  
  /**
   * Display search history
   */
  function renderSearchHistory() {
    if (history.length === 0) {
      searchHistory.innerHTML = '<p>No recent searches</p>';
      return;
    }
    
    const html = history.map(item => `
      <div class="history-pill" onclick="document.getElementById('medicineName').value = '${item}'; document.getElementById('searchBtn').click();">
        <i class="fas fa-history"></i> ${item}
      </div>
    `).join('');
    
    searchHistory.innerHTML = html;
  }
  
  /**
   * Show input error
   */
  function showInputError(inputElement, message) {
    // Highlight input
    inputElement.style.borderColor = 'var(--accent-color)';
    
    // Create or update error message
    let errorElement = inputElement.parentElement.querySelector('.error-message');
    
    if (!errorElement) {
      errorElement = document.createElement('div');
      errorElement.className = 'error-message';
      errorElement.style.color = 'var(--accent-color)';
      errorElement.style.fontSize = '0.8rem';
      errorElement.style.marginTop = '0.5rem';
      inputElement.parentElement.appendChild(errorElement);
    }
    
    errorElement.textContent = message;
    
    // Clear error after 3 seconds
    setTimeout(() => {
      inputElement.style.borderColor = '';
      if (errorElement) {
        errorElement.remove();
      }
    }, 3000);
  }
  
  // Pre-fill input and execute search if URL has query parameter
  const urlParams = new URLSearchParams(window.location.search);
  const medicineParam = urlParams.get('medicine');
  
  if (medicineParam) {
    medicineNameInput.value = medicineParam;
    searchMedicine();
  }
}
/* Medicine Gallery Section - Add this to your details.css file */
.medicine-gallery-section {
  padding: 4rem 0;
  background-color: var(--background-light);
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.medicine-gallery-section h2 {
  text-align: center;
  margin-bottom: 0.5rem;
  color: var(--text-color);
}

.gallery-description {
  text-align: center;
  color: var(--text-light);
  margin-bottom: 2.5rem;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.medicine-gallery {
  display: flex;
  flex-direction: column;
  gap: 2.5rem;
}

.gallery-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.5rem;
}

.medicine-card {
  background-color: var(--white);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow);
  overflow: hidden;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  cursor: pointer;
}

.medicine-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.medicine-image {
  height: 180px;
  overflow: hidden;
  position: relative;
  background-color: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.medicine-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.medicine-card:hover .medicine-image img {
  transform: scale(1.05);
}

.medicine-description {
  padding: 1.2rem;
}

.medicine-description h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  color: var(--primary-color);
}

.medicine-description p {
  margin: 0;
  font-size: 0.9rem;
  color: var(--text-light);
  line-height: 1.5;
}

/* Responsive adjustments for gallery */
@media screen and (max-width: 1200px) {
  .gallery-row {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media screen and (max-width: 992px) {
  .gallery-row {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media screen and (max-width: 576px) {
  .gallery-row {
    grid-template-columns: 1fr;
  }
  
  .medicine-image {
    height: 220px;
  }
});
