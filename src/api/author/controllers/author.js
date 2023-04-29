'use strict';

/**
 * author controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::author.author', ({ strapi }) => ({
    async findBySlug(ctx) {
        const { slug } = ctx.params;

        ctx.query = {
            filters: { slug },
            ...ctx.query,
        };

        const { data } = await super.find(ctx);
        const author = data[0] ? data[0] : 'Not found';
        return { author };
    },
}));
