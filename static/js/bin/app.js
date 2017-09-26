/* include util.js */
/* include authorize.js */
/* include model.js */
/* include models.js */
/* include vehicles.js */
/* include routes.js */

$(function(){

    const Vehicles = { template: ht('div.vehicles') };
    const Drivers  = { template: ht('div.drivers') };
    const Rides    = { template: ht('div.rides') };

    const routes = [
      { path: '/login', component: LoginVue, props: true },
      { path: '/routes', component: rfRoutes },
      { path: '/routes/new', component: rfEditRoute },
      { path: '/routes/:id/edit', component: rfEditRoute, props: true },
      { path: '/vehicles', component: rfVehicles },
      { path: '/vehicles/new', component: rfEditVehicle },
      { path: '/vehicles/:id', component: rfVehicle, props: true },
      { path: '/vehicles/:id/edit', component: rfEditVehicle, props: true },
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
            route: {
                name: 'route name',
                create: 'add route',
                update: 'save changes'
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
            },
            login: {
              email: 'Email',
              password: 'Password'
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

