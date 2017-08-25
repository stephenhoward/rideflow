/* include util.js */

$(function() {

    window.rfVehicles = {
        template: ht('div.vehicles'),
        data: function(){
            return {
                loading : false,
                models  : [],
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
            add: function() {
                this.$router.push('/vehicles/new');
            },
            fetchData: function() {
                console.log('get list of data...');
            }
        }
    };

    window.rfEditVehicle = {
        template: ht('div.edit_vehicle'),
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
                console.log('fetching...?');
            }
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