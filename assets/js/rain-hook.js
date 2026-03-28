// LiveView Hook for Server-Driven Rain Effect
export const RainEffect = {
  mounted() {
    console.log('RainEffect hook mounted');
    this.rainPanel = null;
    this.droplets = new Map(); // Track droplets by ID
    
    // Initialize rain panel
    this.initRainPanel();
    
    // Listen for server events
    this.handleEvent("rain_update", ({ droplets }) => {
      console.log('Received initial rain droplets:', droplets.length);
      this.clearRain();
      droplets.forEach(droplet => this.addDroplet(droplet));
    });
    
    this.handleEvent("rain_new_droplets", ({ droplets }) => {
      console.log('Received new rain droplets:', droplets.length);
      droplets.forEach(droplet => this.addDroplet(droplet));
      // Remove old droplets if we have too many
      this.pruneDroplets();
    });
  },
  
  destroyed() {
    console.log('RainEffect hook destroyed');
    this.clearRain();
    if (this.rainPanel) {
      this.rainPanel.remove();
    }
  },
  
  initRainPanel() {
    // Create rain panel container
    this.rainPanel = document.createElement('div');
    this.rainPanel.className = 'rain-panel';
    this.el.appendChild(this.rainPanel);
  },
  
  addDroplet(dropletData) {
    // Create SVG element for the droplet
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.classList.add('rain__drop');
    svg.setAttribute('preserveAspectRatio', 'xMinYMin');
    svg.setAttribute('viewBox', '0 0 5 50');
    svg.dataset.dropletId = dropletData.id;
    
    // Apply server-provided properties
    svg.style.setProperty('--x', dropletData.x);
    svg.style.setProperty('--y', dropletData.y);
    svg.style.setProperty('--o', dropletData.opacity);
    svg.style.setProperty('--a', dropletData.animation_duration);
    svg.style.setProperty('--d', dropletData.delay);
    svg.style.setProperty('--s', dropletData.scale);
    
    // Create the raindrop path
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('stroke', 'none');
    path.setAttribute('d', 'M 2.5,0 C 2.6949458,3.5392017 3.344765,20.524571 4.4494577,30.9559 5.7551357,42.666753 4.5915685,50 2.5,50 0.40843152,50 -0.75513565,42.666753 0.55054234,30.9559 1.655235,20.524571 2.3050542,3.5392017 2.5,0 Z');
    
    svg.appendChild(path);
    this.rainPanel.appendChild(svg);
    
    // Track the droplet
    this.droplets.set(dropletData.id, {
      element: svg,
      data: dropletData,
      timestamp: Date.now()
    });
    
    // Remove droplet after animation completes
    const totalDuration = (dropletData.animation_duration + dropletData.delay) * 1000;
    setTimeout(() => {
      this.removeDroplet(dropletData.id);
    }, totalDuration + 1000);
  },
  
  removeDroplet(dropletId) {
    const droplet = this.droplets.get(dropletId);
    if (droplet) {
      droplet.element.remove();
      this.droplets.delete(dropletId);
    }
  },
  
  clearRain() {
    this.droplets.forEach((droplet, id) => {
      droplet.element.remove();
    });
    this.droplets.clear();
  },
  
  pruneDroplets() {
    // Keep maximum of 100 droplets
    if (this.droplets.size > 100) {
      const sortedDroplets = Array.from(this.droplets.entries())
        .sort((a, b) => a[1].timestamp - b[1].timestamp);
      
      const toRemove = sortedDroplets.slice(0, this.droplets.size - 100);
      toRemove.forEach(([id]) => this.removeDroplet(id));
    }
  }
};