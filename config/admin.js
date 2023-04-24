module.exports = ({ env }) => ({
  auth: {
    secret: env('ADMIN_JWT_SECRET'),
  },
  apiToken: {
    salt: env('API_TOKEN_SALT'),
  },
  // url: env.NODE_ENV === 'production' ? 'https://cms.winewithmargaret.com/' : '/',
  url: 'https://cms.winewithmargaret.com',
  // serveAdminPanel: env.NODE_ENV === 'production' ? false : true,
  serveAdminPanel: false,
});
