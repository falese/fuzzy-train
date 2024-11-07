import * as React from 'react';
import Button from '@mui/material/Button';
import { createTheme, ThemeProvider } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '2' === '1' ? '#2196F3' : 
            '2' === '2' ? '#4CAF50' : '#FF9800',
    },
  },
});

const App = () => {
  const muiVersion = require('@mui/material/package.json').version;
  
  return (
    <ThemeProvider theme={theme}>
      <div style={{ padding: '20px', border: '1px solid #ccc', margin: '10px' }}>
        <h3>mfe2 using MUI {muiVersion}</h3>
        <Button
          variant="contained"
          color="primary"
          onClick={() => alert('mfe2 button clicked! Using MUI ' + muiVersion)}
        >
          MUI Button
        </Button>
      </div>
    </ThemeProvider>
  );
};

export default App;
