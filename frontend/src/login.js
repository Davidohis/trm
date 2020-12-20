import * as React from 'react';
import { useLogin, useNotify, Notification } from 'react-admin';
import { ThemeProvider, makeStyles, styled } from '@material-ui/styles';
import Paper from '@material-ui/core/Paper';
import CssBaseline from '@material-ui/core/CssBaseline';
import { createMuiTheme } from '@material-ui/core/styles';
import GREY from '@material-ui/core/colors/grey';
import Button from '@material-ui/core/Button';
import { GoogleLogin } from 'react-google-login';

import config from './config'
import { ReactComponent as TechLabsLogo } from './static/techlabs-logo.svg';

const LoginPaper = styled(Paper)({
    padding: '30px',
});

export const loginTheme = createMuiTheme({
    palette: {
      background: {
        default: GREY[200]
      }
    },
    typography: {
        fontFamily: ['Nunito Sans', 'Helvetica', 'Arial', 'sans-serif']
    }
});

const useStyles = makeStyles({
    root: {
        width: '400px',
        position: 'absolute',
        left: '50%',
        top: '50%',
        '-webkit-transform': 'translate(-50%, -50%)',
        transform: 'translate(-50%, -50%)'
    },
    centeredBlock: {
        'margin-left': 'auto',
        'margin-right': 'auto'
    },
    centeredText: {
        'text-align': 'center'
    }
});


const LoginPage = (props) => {
    const notify = useNotify();
    const login = useLogin();
    const classes = useStyles(props);
    const onProviderResponse = (response) => {
        if('code' in response) {
            login({ code: response.code })
            return
        }
        console.error(response)
        notify('Sign in with Google failed')
    }

    return (
        <ThemeProvider theme={loginTheme}>
            <CssBaseline />
            <Notification />
            <div className={classes.root}>
                <LoginPaper elevation={3} className={classes.centeredText}>
                    <TechLabsLogo className={classes.centeredBlock} alt="TechLabs Logo" />
                    <h1 className={classes.centeredText}>Techie Relationship Management</h1>
                    {config.auth === 'oauth' && (
                        <GoogleLogin
                            clientId={config.oauth.clientId}
                            hostedDomain={config.oauth.hostedDomain}
                            scope="profile email openid"
                            responseType="code"
                            onSuccess={onProviderResponse}
                            onFailure={onProviderResponse}
                            cookiePolicy={'single_host_origin'}
                        />
                    )}
                    {config.auth === 'stub' && (
                        <Button
                            variant="contained"
                            color="primary"
                            onClick={() => onProviderResponse({code: 'stub'})}>
                            Log In
                        </Button>
                    )}
                </LoginPaper>
            </div>
        </ThemeProvider>
    );
};

export default LoginPage;
