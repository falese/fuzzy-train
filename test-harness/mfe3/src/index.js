const mount = (containerId) => {
    // Use the version-specific shared library
    if (window.sharedLib_v3) {
        window.sharedLib_v3.render(containerId, 'Mounted from mfe3');
    } else {
        console.error('Shared library v3 not loaded!');
    }
};

// Export mount function
export { mount };

// Mount if in standalone mode
if (!window.__POWERED_BY_FEDERATION__) {
    mount('mfe3-root');
}
