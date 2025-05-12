// Toggle mobile navigation
document.querySelector('.hamburger').addEventListener('click', function() {
  this.classList.toggle('active');
  document.querySelector('.nav-links').classList.toggle('active');
});

function searchByIndication() {
  const indication = document.getElementById('indication').value.trim();
  if (!indication) {
    alert('Please enter a condition, symptom, or indication to search');
    return;
  }

  // Show loading indicator
  document.getElementById('loadingIndicator').style.display = 'flex';
  document.getElementById('indicationResult').style.display = 'none';

  // Make API request to Flask backend
  fetch(`/search_by_indication?indication=${encodeURIComponent(indication)}`)
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      // Hide loading indicator
      document.getElementById('loadingIndicator').style.display = 'none';
      const resultContainer = document.getElementById('indicationResult');
      resultContainer.style.display = 'block';
      
      if (data.medicines_for_indication && data.medicines_for_indication.length > 0) {
        const medicineList = data.medicines_for_indication;
        resultContainer.innerHTML = `
          <h2 class="result-heading">
            <i class="fas fa-pills"></i> Medications for "${indication}"
          </h2>
          <ul class="medicine-list">
            ${medicineList.map(medicine => `
              <li class="medicine-item" onclick="window.location.href='details.html?medicine=${encodeURIComponent(medicine)}'">
                <i class="fas fa-capsules"></i>
                <span class="medicine-name">${medicine}</span>
              </li>
            `).join('')}
          </ul>
        `;
      } else {
        resultContainer.innerHTML = `
          <div class="no-results">
            <i class="fas fa-search"></i>
            <h3>No medications found</h3>
            <p>We couldn't find any medications for "${indication}" in our database.</p>
            <p>Try using different terms or check your spelling.</p>
          </div>
        `;
      }
    })
    .catch(error => {
      console.error('Error:', error);
      document.getElementById('loadingIndicator').style.display = 'none';
      const resultContainer = document.getElementById('indicationResult');
      resultContainer.style.display = 'block';
      resultContainer.innerHTML = `
        <div class="no-results">
          <i class="fas fa-exclamation-triangle"></i>
          <h3>Something went wrong</h3>
          <p>There was an error processing your request. Please try again later.</p>
        </div>
      `;
    });
}

// Allow searching by pressing Enter key
document.getElementById('indication').addEventListener('keypress', function(e) {
  if (e.key === 'Enter') {
    searchByIndication();
  }
});