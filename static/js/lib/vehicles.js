/* include util.js */

$(function() {

    window.ListVueMixin = {
        data: () => {
            return {
                loading : false,
                models  : [
                ],
                error   : null
            };            
        },
        created: function() {
            this.fetchData();
        },
        watch: {
            '$route': 'fetchData'
        },
        methods: {
            type: function() { return null },
            url:  function() { return ''   },

            add: function() {
                this.$router.push( this.url() + '/new' );
            },
            fetchData: function() {
                let defer = $.Deferred();
                let type  = this.type();

                type.list( '/v1' + this.url() ).done( (items) => {
                    this.models = items;
                });

                return defer.promise();
            }
        }
    };

    window.rfVehicles = {
        template: ht('div.vehicles'),
        mixins: [ ListVueMixin ],

        methods: {
            type: () => { return Vehicle },
            url:  () => { return '/vehicles' }
        }
    };

    Vue.component('vehicle-summary',{
        template: ht('li.vehicle-summary'),
        props: ['model'],
        data: function() {
            return {};
        }
    });

    window.EditVueMixin = {
        props: ['id'],
        data: function() {
            return {
                loading: false,
                model  : null,
                error  : null
            };
        },
        created: function() {
            this.fetchData();
        },
        watch: {
           '$route': 'fetchData' 
        },
        methods: {
            fetchData: function() {
                let defer = $.Deferred();
                if ( ! this.model ) {
                    let type = this.type();
                    this.model = new type({});
                    if ( this.id ) {
                        type.load( '/v1' + this.url() + '/'+this.id).done( (model) => {
                            this.model = model;
                            defer.resolve(this.model);
                        });
                    }
                }
                else {
                    defer.resolve(this.model);
                }
                return defer.promise();
            },
            saveData: function() {
                if ( this.model.id ) {
                    this.model.save( '/v1' + this.url() + '/' + this.model.id );
                }
                else {
                    this.model.save( '/v1' + this.url() );
                }
            }
        }

    }

    window.rfEditVehicle = {
        template: ht('div.edit_vehicle'),
        mixins: [ EditVueMixin ],

        methods: {
            type: () => { return Vehicle },
            url:  () => { return '/vehicles' }
        }
    };

    window.rfVehicle = {
        template: ht('div.edit_vehicle'),
        data: function() {
            return {
                loading: false,
                model  : null,
                error  : null
            };
        },
    };

});