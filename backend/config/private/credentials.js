module.exports = {
    facebook: {
        appID: 'YOUR_FB_APP_ID',
        secret: 'YOUR_FB_APP_SECRET'
    },
    app: {
        accessTokenKey: Buffer.from('YOUR_ACCESS_TOKEN_KEY'),
        refreshTokenKey: Buffer.from('YOUR_REFRESH_TOKEN_KEY'),
        postgresServiceName: 'compose-for-postgresql'
    },
    email: {
        userName: 'YOUR_EMAIL_USER_NAME',
        domainName: 'YOUR_EMAIL_DOMAIN_NAME',
        displayUserName: 'YOUR_EMAIL_USER_NAME',
        displayDomainName: 'YOUR_EMAIL_DOMAIN_NAME',
        password: 'YOUR_EMAIL_PASSWORD'
    },
    sessionSecret: "YOUR_SESSION_SECRET"
};
