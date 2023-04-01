'use strict';

/**
 * article controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::article.article', ({ strapi }) => ({
    async findBySlug(ctx) {
        const { slug } = ctx.params;
        console.log('Called');
        console.log(''.padEnd(80, '*'));

        // const query = {
        //     filters: { slug },
        //     ...ctx.query,
        // };

        // const article = await strapi.entityService.findMany('api::article.article', query);

        ctx.query = {
            filters: { slug },
            ...ctx.query,
        };

        const { data, meta } = await super.find(ctx);
        return { data, meta };
    },
}));
