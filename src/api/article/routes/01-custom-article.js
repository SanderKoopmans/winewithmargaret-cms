module.exports = {
    routes: [
        {
            method: 'GET',
            path: '/articles/find-by-slug/:slug',
            handler: 'api::article.article.findBySlug',
            config: {
                auth: {
                    scope: ['find'],
                },
            },
        },
    ]
};
