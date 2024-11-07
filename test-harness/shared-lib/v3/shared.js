(function() {
    console.log('Loading shared library v3.0.0');
    window.sharedLib_v3 = {
        version: '3.0.0',
        render: function(containerId, data) {
            console.log('Rendering with shared lib v3.0.0');
            const element = document.createElement('div');
            element.textContent = `Rendered by Shared Library v3.0.0 - ${data}`;
            document.getElementById(containerId).appendChild(element);
            // Add a timestamp to verify caching
            const timestamp = document.createElement('div');
            timestamp.style.fontSize = '0.8em';
            timestamp.style.color = '#666';
            timestamp.textContent = `Loaded at: ${new Date().toISOString()}`;
            document.getElementById(containerId).appendChild(timestamp);
        }
    };
})();