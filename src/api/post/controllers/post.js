'use strict';

/**
 * post controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::post.post', ({ strapi }) => ({
    async findBySlug(ctx) {
        const { slug } = ctx.params;

        ctx.query = {
            filters: { slug },
            ...ctx.query,
        };

        const { data, meta } = await super.find(ctx);
        return { data, meta };
    },
}));
