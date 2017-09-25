
(function() {

var jwt = null

function login (email,password) {

    $.ajax({
        url         : '/v1/auth/login',
        type        : 'POST',
        contentType : 'application/json; charset=utf-8',
        data: JSON.stringify({
            email    : email,
            password : password
        })
    }).done( (data) => {
        jwt = data;

    }).fail( (data) => {
        var json = JSON.parse(data);
        jwt      = null;

    });
}

function refresh_login() {

    $.ajax({
        url  : '/v1/auth/refresh',
        type : 'GET',
    }).done( (data) => {
        jwt = data;

    }).fail( (data) => {
        var json = JSON.parse(data);
        jwt      = null;

    });
}

$.ajaxSetup({
    beforeSend: function(xhr) {
        if ( jwt ) {
            xhr.setRequestHeader( 'Authorization': 'Bearer ' + jwt );
        }
    }
});

})();
