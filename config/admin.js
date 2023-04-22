module.exports = ({ env }) => ({
  auth: {
    secret: env('ADMIN_JWT_SECRET'),
  },
  apiToken: {
    salt: env('API_TOKEN_SALT'),
  },
  // url: env.NODE_ENV === 'production' ? 'https://cms.winewithmargaret.com/' : '/',
  // url: '/',
  // serveAdminPanel: env.NODE_ENV === 'production' ? false : true,
  serveAdminPanel: false,
});

// module.exports = ({ env }) => ({
//   url: '/', // Note: The administration will be accessible from the root of the domain (ex: http://yourfrontend.com/)
//   serveAdminPanel: false, // http://yourbackend.com will not serve any static admin files
// });
