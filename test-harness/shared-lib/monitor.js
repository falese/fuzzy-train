window.depMonitor = {
  loads: {},
  log: function(name, version, source, loadTime) {
    this.loads[name] = {
      version,
      source,
      loadTime,
      timestamp: new Date().toISOString()
    };
    console.log(`[Dep Monitor] ${name}@${version} loaded from ${source} in ${loadTime}ms`);
  }
};
