import React, { Suspense } from 'react';

const MFE1 = React.lazy(() => import('mfe1/App'));
const MFE2 = React.lazy(() => import('mfe2/App'));
const MFE3 = React.lazy(() => import('mfe3/App'));

const App = () => {
  return (
    <div style={{ padding: '20px' }}>
      <h1>MUI Version Testing</h1>
      <div style={{ marginBottom: '20px' }}>
        <h2>Testing different MUI versions:</h2>
        <ul>
          <li>MFE1: MUI v5.13.7</li>
          <li>MFE2: MUI v5.14.7</li>
          <li>MFE3: MUI v5.15.1</li>
        </ul>
      </div>
      <div>
        <Suspense fallback={<div>Loading MFE1...</div>}>
          <MFE1 />
        </Suspense>
        <Suspense fallback={<div>Loading MFE2...</div>}>
          <MFE2 />
        </Suspense>
        <Suspense fallback={<div>Loading MFE3...</div>}>
          <MFE3 />
        </Suspense>
      </div>
    </div>
  );
};

export default App;
