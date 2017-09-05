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

    Vue.component('route-summary',{
        template: ht('li.route-summary'),
        props: ['model'],
        data: function() {
            return {};
        }
    });

    window.rfEditRoute = {
        template: ht('div.edit_route'),
        mixins: [ EditVueMixin ],

        methods: {
            type: () => { return Route },
            url:  () => { return '/routes' }
        }
    };
});