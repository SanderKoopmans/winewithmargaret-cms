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
        
        const { data } = await super.find(ctx);
        const query = strapi.db.query('api::post.post');
        await Promise.all(
          data.map(async (item, index) => {
            const foundItem = await query.findOne({
              where: {
                id: item.id,
              },
              populate: ['createdBy', 'updatedBy'],
            });
            
            data[index].attributes.createdBy = {
              id: foundItem.createdBy.id,
              firstname: foundItem.createdBy.firstname,
              lastname: foundItem.createdBy.lastname,
            };
            data[index].attributes.updatedBy = {
              id: foundItem.updatedBy.id,
              firstname: foundItem.updatedBy.firstname,
              lastname: foundItem.updatedBy.lastname,
            };
          })
        );

        const post = data[0] ? data[0] : 'Not found';
        return { post };
    },

    async find(ctx) {
        // Calling the default core action
        const { data, meta } = await super.find(ctx);
        const query = strapi.db.query('api::post.post');
        await Promise.all(
          data.map(async (item, index) => {
            const foundItem = await query.findOne({
              where: {
                id: item.id,
              },
              populate: ['createdBy', 'updatedBy'],
            });
            
            data[index].attributes.createdBy = {
              id: foundItem.createdBy.id,
              firstname: foundItem.createdBy.firstname,
              lastname: foundItem.createdBy.lastname,
            };
            data[index].attributes.updatedBy = {
              id: foundItem.updatedBy.id,
              firstname: foundItem.updatedBy.firstname,
              lastname: foundItem.updatedBy.lastname,
            };
          })
        );
        return { data, meta };
      },
}));
