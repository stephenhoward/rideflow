/* include util.js */
/* include routes.js */
/* include vehicles.js */

$(function(){

    const Vehicles = { template: ht('div.vehicles') };
    const Drivers  = { template: ht('div.drivers') };
    const Rides    = { template: ht('div.rides') };

    const routes = [
      { path: '/routes', component: rfRoutes },
      { path: '/vehicles', component: rfVehicles },
      { path: '/vehicles/new', component: rfEditVehicle },
      { path: '/vehicles/:id', component: rfVehicle },
      { path: '/vehicles/:id/edit', component: rfEditVehicle },
      { path: '/drivers',  component: Drivers },
      { path: '/rides',    component: Rides }
    ];

    const messages = {
        en: {
            routes: {
                nav: 'Routes',
                title: 'Routes',
                add_title: 'Add Route'
            },
            vehicles: {
                nav: 'Vehicles',
                title: 'Vehicles',
                add_title: 'Add Vehicle'
            },
            vehicle: {
                name: 'vehicle identifier',
                create: 'add vehicle',
                update: 'save changes'
            },
            drivers: {
                nav: 'Drivers'
            },
            rides: {
                nav: 'Ride Data'
            }
        }
    };

    // Create VueI18n instance with options
    const i18n = new VueI18n({
        locale   : 'en',
        messages : messages
    });

    const router = new VueRouter({
      routes : routes
    });

    window.app = new Vue({
      router : router,
      i18n   : i18n
    }).$mount('#rfapp');

});

