import * as React from 'react';
import Button from '@mui/material/Button';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';

const theme = createTheme({
  palette: {
    primary: {
      main: '1' === '1' ? '#2196F3' : 
            '1' === '2' ? '#4CAF50' : '#FF9800',
    },
  },
});

const App = () => {
  const [depInfo, setDepInfo] = React.useState({ loading: true });
  const startTime = React.useRef(Date.now());

  React.useEffect(() => {
    const muiVersion = require('@mui/material/package.json').version;
    const containerVersion = '5.13.7'; // Container's MUI version
    const loadTime = Date.now() - startTime.current;
    
    // Determine if using container's version
    const isUsingContainer = muiVersion === containerVersion;
    
    const info = {
      loading: false,
      version: muiVersion,
      source: isUsingContainer ? 'container' : 'local',
      loadTime
    };
    
    setDepInfo(info);
    
    // Log to console monitor
    console.log(`[mfe1] MUI ${muiVersion} loaded from ${info.source} in ${loadTime}ms`);
    
    // Log performance mark
    performance.mark(`mfe1-mui-loaded`);
  }, []);

  return (
    <ThemeProvider theme={theme}>
      <Card sx={{ minWidth: 275, mb: 2 }}>
        <CardContent>
          <Typography variant="h5" component="div">
            mfe1
          </Typography>
          {depInfo.loading ? (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <CircularProgress size={20} />
              <Typography color="text.secondary">
                Loading dependencies...
              </Typography>
            </Box>
          ) : (
            <>
              <Typography color="text.secondary" gutterBottom>
                MUI Version: {depInfo.version}
              </Typography>
              <Typography color="text.secondary" gutterBottom>
                Source: {depInfo.source}
              </Typography>
              <Typography color="text.secondary" gutterBottom>
                Load Time: {depInfo.loadTime}ms
              </Typography>
              <Button
                variant="contained"
                color="primary"
                onClick={() => alert(`mfe1 using MUI ${depInfo.version} from ${depInfo.source}`)}
              >
                MUI Button
              </Button>
            </>
          )}
        </CardContent>
      </Card>
    </ThemeProvider>
  );
};

export default App;
