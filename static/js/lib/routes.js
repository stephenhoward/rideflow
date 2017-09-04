/* include util.js */

$(function() {

    window.rfRoutes = {
        template: ht('div.routes'),
        mixins: [ ListVueMixin ],

        methods: {
            type: () => { return Route },
            url:  () => { return '/routes' }
        }
    };

    window.rfEditRoute = {
        template: ht('div.edit_route'),
        mixins: [ EditVueMixin ],

        methods: {
            type: () => { return Route },
            url:  () => { return '/routes' }
        }
    };
});