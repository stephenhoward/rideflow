/* include util.js */

$(function() {

var jwt = null

window.LoginVue = {
    template : ht('div.login'),
    props    : ['error'],
    data     : () => {

        return {
            email    : '',
            password : ''
        };

    },
    methods : {
        doLogin: function() {
            console.log(this);
            console.log(this.email);
            console.log(this.password);
            login(this.email,this.password)
                .done(() => {
                    console.log(jwt);
                })
                .fail((error) => {
                    this.error = error;
                });
        }

    }
}

function login (email,password) {

    var defer = $.Deferred();

    $.ajax({
        url         : '/v1/auth/token',
        type        : 'POST',
        contentType : 'application/json; charset=utf-8',
        data: JSON.stringify({
            email    : email,
            password : password
        })
    }).done( (data) => {
        jwt = data;

    }).fail( (xhr) => {
        var json = JSON.parse(xhr.responseText);
        console.log(json);
        jwt      = null;

    });

    return defer.promise();
}

function refresh_login() {

    $.ajax({
        url  : '/v1/auth/token',
        type : 'GET',
    }).done( (data) => {
        jwt = data;

    }).fail( (xhr) => {
        var json = JSON.parse(data);
        jwt      = null;

    });
}

$.ajaxSetup({
    beforeSend: (xhr) => {
        if ( jwt ) {
            xhr.setRequestHeader( 'Authorization', 'Bearer ' + jwt );
        }
    },
    statusCode: {
        401: (xhr,err,error_text) => {
            console.log('need to log in');
            console.log(error_text);
            window.app.$router.push({ path: '/login', query: { error: xhr.status } });
        }
    }
});

});
