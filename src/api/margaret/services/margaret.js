'use strict';

/**
 * margaret service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::margaret.margaret');
