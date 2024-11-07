import React, { Suspense } from 'react';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';

const MFE1 = React.lazy(() => import('mfe1/App'));
const MFE2 = React.lazy(() => import('mfe2/App'));
const MFE3 = React.lazy(() => import('mfe3/App'));

const theme = createTheme();

const LoadingFallback = () => (
  <Paper sx={{ p: 2, m: 1 }}>
    <Typography>Loading MFE...</Typography>
  </Paper>
);

const App = () => {
  return (
    <ThemeProvider theme={theme}>
      <Box sx={{ p: 3 }}>
        <Typography variant="h4" gutterBottom>
          MUI Version Testing with Dependency Monitoring
        </Typography>
        
        <Paper sx={{ p: 2, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            Container MUI Version: 5.13.7
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Container provides shared dependencies with host-first configuration
          </Typography>
        </Paper>

        <Suspense fallback={<LoadingFallback />}>
          <MFE1 />
        </Suspense>
        
        <Suspense fallback={<LoadingFallback />}>
          <MFE2 />
        </Suspense>
        
        <Suspense fallback={<LoadingFallback />}>
          <MFE3 />
        </Suspense>

        <Paper sx={{ p: 2, mt: 3 }}>
          <Typography variant="body2" color="text.secondary">
            Check browser console for detailed dependency loading information
          </Typography>
        </Paper>
      </Box>
    </ThemeProvider>
  );
};

export default App;
