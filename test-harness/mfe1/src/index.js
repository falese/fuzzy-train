const mount = (containerId) => {
    // Use the version-specific shared library
    if (window.sharedLib_v1) {
        window.sharedLib_v1.render(containerId, 'Mounted from mfe1');
    } else {
        console.error('Shared library v1 not loaded!');
    }
};

// Export mount function
export { mount };

// Mount if in standalone mode
if (!window.__POWERED_BY_FEDERATION__) {
    mount('mfe1-root');
}
