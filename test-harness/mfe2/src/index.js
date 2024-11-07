const mount = (containerId) => {
    // Use the version-specific shared library
    if (window.sharedLib_v2) {
        window.sharedLib_v2.render(containerId, 'Mounted from mfe2');
    } else {
        console.error('Shared library v2 not loaded!');
    }
};

// Export mount function
export { mount };

// Mount if in standalone mode
if (!window.__POWERED_BY_FEDERATION__) {
    mount('mfe2-root');
}
