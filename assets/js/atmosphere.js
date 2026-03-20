// Victorian Rain Effects - Based on Svelte rain component
export function createAtmosphere() {
  // Create rain panel
  const rainPanel = document.createElement('div');
  rainPanel.className = 'rain-panel';
  
  // Generate 50 rain drops like the Svelte component
  for (let i = 0; i < 50; i++) {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.classList.add('rain__drop');
    svg.setAttribute('preserveAspectRatio', 'xMinYMin');
    svg.setAttribute('viewBox', '0 0 5 50');
    
    // Set CSS custom properties like the Svelte component
    svg.style.setProperty('--x', Math.random() * 100);
    svg.style.setProperty('--y', Math.random() * 100);
    svg.style.setProperty('--o', Math.random());
    svg.style.setProperty('--a', Math.random() * 2 + 1); // 1-3 second animation
    svg.style.setProperty('--d', Math.random() * 3); // 0-3 second delay
    svg.style.setProperty('--s', Math.random() * 0.8 + 0.2); // Scale 0.2-1.0
    
    // Create the raindrop path (same as Svelte component)
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('stroke', 'none');
    path.setAttribute('d', 'M 2.5,0 C 2.6949458,3.5392017 3.344765,20.524571 4.4494577,30.9559 5.7551357,42.666753 4.5915685,50 2.5,50 0.40843152,50 -0.75513565,42.666753 0.55054234,30.9559 1.655235,20.524571 2.3050542,3.5392017 2.5,0 Z');
    
    svg.appendChild(path);
    rainPanel.appendChild(svg);
  }
  
  // Add to document
  document.body.appendChild(rainPanel);
  
  // Cleanup function
  return function cleanup() {
    rainPanel.remove();
  };
}

// Auto-initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  console.log('Rain effect loading on all pages...');
  createAtmosphere();
});

// Also try to initialize immediately if DOM is already loaded
if (document.readyState === 'loading') {
  // DOM is still loading
} else {
  // DOM is already loaded
  console.log('DOM already loaded, initializing rain immediately');
  createAtmosphere();
}

// Initialize rain when navigating with LiveView
document.addEventListener('phx:page-loading-stop', () => {
  // Remove any existing rain first
  const existingRain = document.querySelector('.rain-panel');
  if (existingRain) {
    existingRain.remove();
  }
  // Add fresh rain to the new page
  console.log('LiveView navigation complete, adding rain...');
  createAtmosphere();
});

// Export for manual control
window.VictorianAtmosphere = { createAtmosphere };