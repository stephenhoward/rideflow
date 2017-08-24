(function(){


    const Routes = { template: '<div>routes</div>' };
    const Vehicles = { template: '<div>vehicles</div>' };
    const Drivers = { template: '<div>drivers</div>' };
    const Rides = { template: '<div>rides</div>' };

    const routes = [
      { path: '/routes', component: Routes },
      { path: '/vehicles', component: Vehicles },
      { path: '/drivers', component: Drivers },
      { path: '/rides', component: Rides }
    ];

    const messages = {
        en: {
            nav: {
                routes: 'Routes',
                vehicles: 'Vehicles',
                drivers: 'Drivers',
                rides: 'Ride Data'
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

$(function(){
    window.app = new Vue({
      router : router,
      i18n   : i18n
    }).$mount('#rfapp');
});

})();

