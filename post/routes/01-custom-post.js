module.exports = {
    routes: [
        {
            method: 'GET',
            path: '/posts/find-by-slug/:slug',
            handler: 'api::post.post.findBySlug',
            config: {
                auth: {
                    scope: ['find'],
                },
            },
        },
    ]
};
