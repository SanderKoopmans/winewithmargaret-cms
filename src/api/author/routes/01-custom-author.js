module.exports = {
    routes: [
        {
            method: 'GET',
            path: '/authors/find-by-slug/:slug',
            handler: 'api::author.author.findBySlug',
            config: {
                auth: {
                    scope: ['find'],
                },
            },
        },
    ]
};