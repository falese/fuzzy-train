#!/bin/bash

# Update shared library versions with enhanced display
for version in 1 2 3
do
cat > test-harness/shared-lib/v$version/shared.js << 'EOL'
(function() {
    const version = '${version}.0.0';
    console.log(`Loading shared library v${version}`);
    
    const getVersionColor = (v) => {
        switch(v[0]) {
            case '1': return '#2196F3'; // Blue
            case '2': return '#4CAF50'; // Green
            case '3': return '#FF9800'; // Orange
            default: return '#000000';
        }
    };

    window.sharedLib_v${version} = {
        version: version,
        render: function(containerId, data) {
            const container = document.getElementById(containerId);
            
            // Create styled container
            const wrapper = document.createElement('div');
            wrapper.style.padding = '15px';
            wrapper.style.border = `2px solid ${getVersionColor(version)}`;
            wrapper.style.borderRadius = '8px';
            wrapper.style.margin = '10px 0';
            wrapper.style.backgroundColor = `${getVersionColor(version)}10`;
            
            // Version badge
            const versionBadge = document.createElement('div');
            versionBadge.textContent = `Shared Library v${version}`;
            versionBadge.style.backgroundColor = getVersionColor(version);
            versionBadge.style.color = 'white';
            versionBadge.style.padding = '5px 10px';
            versionBadge.style.borderRadius = '4px';
            versionBadge.style.display = 'inline-block';
            versionBadge.style.marginBottom = '10px';
            wrapper.appendChild(versionBadge);

            // Content
            const content = document.createElement('div');
            content.textContent = `${data}`;
            content.style.marginBottom = '10px';
            wrapper.appendChild(content);

            // Cache info
            const cacheInfo = document.createElement('div');
            cacheInfo.style.fontSize = '0.8em';
            cacheInfo.style.color = '#666';
            cacheInfo.textContent = `Loaded at: ${new Date().toLocaleTimeString()}`;
            wrapper.appendChild(cacheInfo);

            // Clear and append to container
            container.innerHTML = '';
            container.appendChild(wrapper);
        }
    };
})();
EOL
done

# Update MFE source files
for mfe in mfe1 mfe2 mfe3
do
version=${mfe: -1}

cat > test-harness/$mfe/src/index.js << EOL
const mount = (containerId) => {
    // Use the version-specific shared library
    if (window.sharedLib_v${version}) {
        window.sharedLib_v${version}.render(
            containerId,
            'This is ${mfe} using shared library v${version}.0.0'
        );
    } else {
        console.error('Shared library v${version} not loaded!');
        // Display error in container
        const container = document.getElementById(containerId);
        container.innerHTML = \`
            <div style="color: red; padding: 20px; border: 1px solid red; border-radius: 4px;">
                Error: Shared Library v${version} not loaded!
                <br/>
                Check console for details.
            </div>
        \`;
    }
};

// Export mount function
export { mount };

// Mount if in standalone mode
if (!window.__POWERED_BY_FEDERATION__) {
    mount('${mfe}-root');
}
EOL

cat > test-harness/$mfe/src/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>${mfe}</title>
    <script src="/libs/v${version}/shared.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
    </style>
</head>
<body>
    <div id="${mfe}-root"></div>
</body>
</html>
EOL
done

# Update container application
cat > test-harness/container/src/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>MFE Container with Shared Libraries</title>
    <!-- Load all shared library versions -->
    <script src="/libs/v1/shared.js"></script>
    <script src="/libs/v2/shared.js"></script>
    <script src="/libs/v3/shared.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 20px;
            background-color: #f5f5f5;
        }
        
        .header {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .header h1 {
            margin: 0;
            color: #333;
        }
        
        .cache-info {
            background-color: #e3f2fd;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            font-size: 0.9em;
            border-left: 4px solid #2196F3;
        }
        
        .mfe-container {
            background-color: #fff;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .mfe-container h2 {
            margin-top: 0;
            color: #333;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Microfrontend Container with Shared Libraries</h1>
    </div>

    <div class="cache-info">
        <strong>Cache Status:</strong> Check Network tab in DevTools to see X-Cache-Status headers
        <br>
        <strong>Expected:</strong> First load = MISS, Subsequent loads = HIT
    </div>
    
    <div class="mfe-container">
        <h2>MFE 1</h2>
        <div id="mfe1-container"></div>
    </div>
    
    <div class="mfe-container">
        <h2>MFE 2</h2>
        <div id="mfe2-container"></div>
    </div>
    
    <div class="mfe-container">
        <h2>MFE 3</h2>
        <div id="mfe3-container"></div>
    </div>
</body>
</html>
EOL

echo "MFE and shared library updates complete!"
echo "Run the build script again to apply changes:"
echo "cd test-harness"
echo "./build.sh"